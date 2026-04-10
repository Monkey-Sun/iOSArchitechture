import UIKit

@MainActor
private struct UnresolvedNavigationContextRoute: Routable {
    let reason: String

    var navigationStyle: NavigationStyle {
        .present(animated: true, presentation: .formSheet, wrapInNavigation: true)
    }

    var requiresAuthentication: Bool { false }
    var associatedModule: String { "__unresolved_navigation_context__" }
}

@MainActor public protocol RouteNavigating: AnyObject {
    var rootNavigationController: UINavigationController? { get }
    /// 返回由模块解析出的「内容」控制器（用于与 `pop` 锚定），不含为 present 而包在外层的 `UINavigationController`。
    @discardableResult func navigate(to route: Routable, from source: UIViewController?, routing: AppRoutable) -> UIViewController
    func dismiss(from source: UIViewController?, animated: Bool)
    func pop(from source: UIViewController?, animated: Bool)
    func popToRoot(from source: UIViewController?, animated: Bool)
    @discardableResult func replaceRoot(with route: Routable, in window: UIWindow?, embedInNavigation: Bool, routing: AppRoutable) -> UIViewController
}

@MainActor
public final class AppRouter: RouteNavigating {
    public weak var rootNavigationController: UINavigationController?
    private let routeViewResolver: RouteViewResolving
    private var activePushProxies: [ObjectIdentifier: PushTransitionProxy] = [:]

    public init(rootNavigationController: UINavigationController?, routeViewResolver: RouteViewResolving) {
        self.rootNavigationController = rootNavigationController
        self.routeViewResolver = routeViewResolver
    }

    public func navigate(to route: Routable, from source: UIViewController? = nil, routing: AppRoutable) -> UIViewController {
        let destination = routeViewResolver.makeViewController(for: route, routing: routing)
        switch route.navigationStyle {
        case .push(let animated, let transition):
            performPush(destination: destination, source: source, animated: animated, transition: transition, routing: routing)
            return destination
        case .present(let animated, let presentation, let wrapInNavigation, let transition):
            performPresent(
                destination: destination,
                source: source,
                animated: animated,
                presentation: presentation,
                wrapInNavigation: wrapInNavigation,
                transition: transition,
                routing: routing
            )
            return destination
        }
    }

    public func dismiss(from source: UIViewController? = nil, animated: Bool = true) {
        if let source {
            source.dismiss(animated: animated)
            return
        }
        rootNavigationController?.visibleViewController?.dismiss(animated: animated)
    }

    public func pop(from source: UIViewController? = nil, animated: Bool = true) {
        if let nav = source?.navigationController {
            nav.popViewController(animated: animated)
            return
        }
        rootNavigationController?.popViewController(animated: animated)
    }

    public func popToRoot(from source: UIViewController? = nil, animated: Bool = true) {
        if let nav = source?.navigationController {
            nav.popToRootViewController(animated: animated)
            return
        }
        rootNavigationController?.popToRootViewController(animated: animated)
    }

    @discardableResult
    public func replaceRoot(with route: Routable, in window: UIWindow? = nil, embedInNavigation: Bool = true, routing: AppRoutable) -> UIViewController {
        let destination = routeViewResolver.makeViewController(for: route, routing: routing)
        let root: UIViewController = embedInNavigation ? UINavigationController(rootViewController: destination) : destination

        if let nav = root as? UINavigationController {
            rootNavigationController = nav
        } else if let nav = destination as? UINavigationController {
            rootNavigationController = nav
        } else {
            rootNavigationController = nil
        }

        window?.rootViewController = root
        window?.makeKeyAndVisible()
        return destination
    }

    private func performPush(
        destination: UIViewController,
        source: UIViewController?,
        animated: Bool,
        transition: PushTransition,
        routing: AppRoutable
    ) {
        guard let nav = (source as? UINavigationController) ?? source?.navigationController ?? rootNavigationController else {
            assertionFailure("Push failed: no available UINavigationController")
            presentFallbackIfPossible(source: source, routing: routing, reason: "Push failed: no available UINavigationController")
            return
        }

        switch transition {
        case .system:
            nav.pushViewController(destination, animated: animated)
        case .custom(let pushAnimator, let popAnimator):
            let proxy = PushTransitionProxy(pushAnimator: pushAnimator, popAnimator: popAnimator)
            let key = ObjectIdentifier(nav)
            proxy.previousDelegate = nav.delegate
            proxy.onDidShow = { [weak self, weak nav] in
                guard let nav else { return }
                let key = ObjectIdentifier(nav)
                nav.delegate = proxy.previousDelegate
                self?.activePushProxies[key] = nil
            }
            activePushProxies[key] = proxy
            nav.delegate = proxy
            nav.pushViewController(destination, animated: animated)
        }
    }

    private func performPresent(
        destination: UIViewController,
        source: UIViewController?,
        animated: Bool,
        presentation: PresentationStyle,
        wrapInNavigation: Bool,
        transition: PresentTransition,
        routing: AppRoutable
    ) {
        let target: UIViewController
        if wrapInNavigation {
            target = UINavigationController(rootViewController: destination)
        } else {
            target = destination
        }

        switch transition {
        case .system:
            target.modalPresentationStyle = presentation.uiStyle
        case .custom(let delegate, let presentationStyle):
            target.transitioningDelegate = delegate
            target.modalPresentationStyle = presentationStyle
        }

        if let source {
            source.present(target, animated: animated)
            return
        }

        if let presenter = rootNavigationController?.visibleViewController ?? rootNavigationController {
            presenter.present(target, animated: animated)
            return
        }

        assertionFailure("Present failed: no available presenter")
        presentFallbackIfPossible(source: source, routing: routing, reason: "Present failed: no available presenter")
    }

    private func presentFallbackIfPossible(source: UIViewController?, routing: AppRoutable, reason: String) {
        let fallbackRoute = UnresolvedNavigationContextRoute(reason: reason)
        let fallbackVC = routeViewResolver.makeViewController(for: fallbackRoute, routing: routing)
        let target = UINavigationController(rootViewController: fallbackVC)
        if let source {
            source.present(target, animated: true)
            return
        }
        if let presenter = rootNavigationController?.visibleViewController ?? rootNavigationController {
            presenter.present(target, animated: true)
        }
    }
}

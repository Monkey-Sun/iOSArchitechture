import UIKit
import AppRouting

@MainActor
/// 应用级 Coordinator：负责装配模块、管理 Tab 上下文、并统一处理导航/DeepLink/鉴权拦截。
final class AppCoordinator: Coordinating, AppRoutable {
    private let window: UIWindow
    private let authSession: AuthenticationSessionManaging
    private let deepLinkRouter: DeepLinkRouting
    private let tabs: [TabModuleProviding]
    private let rootRouter: RouteNavigating
    private let tabRouter: TabRouter
    private let tabBarController: UITabBarController

    init(
        window: UIWindow,
        tabs: [TabModuleProviding],
        appModules: [AppModuleProviding],
        dependencies: AppDependencies
    ) {
        self.window = window
        self.tabs = tabs
        self.authSession = dependencies.authSession
        self.deepLinkRouter = dependencies.deepLinkRouter

        let routeViewResolver = AppModuleBootstrap()
        routeViewResolver.setUnresolvedRouteFallback(dependencies.notFoundRouteFactory)
        for tab in tabs {
            tab.registerRouteHandlers(name: tab.moduleName, into: routeViewResolver)
            tab.navigationController.tabBarItem = tab.tabBarItem
        }
        for module in appModules {
            module.registerRouteHandlers(name: module.moduleName, into: routeViewResolver)
        }

        let navMap = Dictionary(uniqueKeysWithValues: tabs.map { ($0.tabIndex, $0.navigationController) })

        let tabBar = UITabBarController()
        tabBar.viewControllers = tabs.map(\.navigationController)
        self.tabBarController = tabBar

        self.tabRouter = TabRouter(
            tabBarController: tabBar,
            navMap: navMap
        )
        self.rootRouter = AppRouter(
            rootNavigationController: tabs.first?.navigationController,
            routeViewResolver: routeViewResolver
        )
    }

    func start() {
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()

        if let firstModule = tabs.first {
            route(firstModule.initialRoute())
        }
    }

    func route(_ requestedRoute: Routable, from source: UIViewController? = nil) {
        if requestedRoute is LoginRoute {
            performRouteReturningContent(
                LoginRoute.login { [weak self] login in
                    guard let self else { return }
                    if login {
                        self.authSession.markAuthenticated()
                    }
                },
                resolvedSource: source
            )
            return
        }
        if requestedRoute.requiresAuthentication && !authSession.isAuthenticated {
            performRouteReturningContent(
                LoginRoute.login { [weak self] login in
                    guard let self else { return }
                    if login {
                        self.authSession.markAuthenticated()
                        self.route(requestedRoute, from: source)
                    }
                },
                resolvedSource: source
            )
            return
        }
        let resolvedSource = prepareNavigationContext(for: requestedRoute, source: source)
        performRouteReturningContent(requestedRoute, resolvedSource: resolvedSource)
    }

    func handleDeepLink(_ url: URL, from source: UIViewController?) {
        guard let routeToNavigate = deepLinkRouter.route(for: url) else {
            route(UnresolvedDeepLinkRoute.notFound(originalRouteType: url.absoluteString), from: source)
            return
        }
        route(routeToNavigate, from: source)
    }

    func pop(from source: UIViewController?, animated: Bool = true) {
        performPhysicalDismissOrPop(from: source, animated: animated)
    }

    func popToRoot(in tabIndex: Int? = nil, animated: Bool = true) {
        var source: UIViewController?
        if let tabIndex {
            tabRouter.select(tabIndex)
            source = tabRouter.navigationController(for: tabIndex)?.visibleViewController
        }
        rootRouter.popToRoot(from: source, animated: animated)
    }

    func replaceRoot(with route: Routable, embedInNavigation: Bool = true) {
        rootRouter.replaceRoot(with: route, in: window, embedInNavigation: embedInNavigation, routing: self)
    }

    private func performPhysicalDismissOrPop(from source: UIViewController?, animated: Bool) {
        guard let source else {
            rootRouter.pop(from: nil, animated: animated)
            return
        }
        guard source.viewIfLoaded?.window != nil else { return }

        if let nav = source.navigationController,
           nav.viewControllers.first === source,
           nav.presentingViewController != nil {
            nav.dismiss(animated: animated)
            return
        }
        if source.presentingViewController != nil {
            source.dismiss(animated: animated)
            return
        }
        rootRouter.pop(from: source, animated: animated)
    }

    /// 执行一次导航并返回被解析出的“内容”控制器（不包含为 present 而包裹的导航控制器）。
    @discardableResult
    private func performRouteReturningContent(_ route: Routable, resolvedSource: UIViewController?) -> UIViewController {
        rootRouter.navigate(to: route, from: resolvedSource, routing: self)
    }

    private func prepareNavigationContext(for route: Routable, source: UIViewController?) -> UIViewController? {
        if let ownerModule = tabs.first(where: { $0.moduleName == route.associatedModule }) {
            tabRouter.select(ownerModule.tabIndex)
            let nav = tabRouter.navigationController(for: ownerModule.tabIndex)

            if case .present = route.navigationStyle {
                if let source, source.viewIfLoaded?.window != nil {
                    return source
                }
                if let presenter = windowPresentingChainLeaf() {
                    return presenter
                }
            }

            return source ?? nav?.visibleViewController ?? nav
        }
        return source
    }

    /// 当前窗口上最顶层的展示链末端（用于无明确 source 时的 Modal，避免从未加入层级的 Tab 导航器上 present）。
    private func windowPresentingChainLeaf() -> UIViewController? {
        var current = window.rootViewController
        while let presented = current?.presentedViewController {
            current = presented
        }
        return current
    }
}

import UIKit

@MainActor final class PushTransitionProxy: NSObject, UINavigationControllerDelegate {
    let pushAnimator: UIViewControllerAnimatedTransitioning
    let popAnimator: UIViewControllerAnimatedTransitioning?
    weak var previousDelegate: UINavigationControllerDelegate?
    weak var trackedViewController: UIViewController?
    var hasShownTrackedViewController = false
    var onDidFinishTrackedPop: (() -> Void)?
    private let popInteractionController = NavigationPopInteractionController()

    init(
        pushAnimator: UIViewControllerAnimatedTransitioning,
        popAnimator: UIViewControllerAnimatedTransitioning?
    ) {
        self.pushAnimator = pushAnimator
        self.popAnimator = popAnimator
    }

    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            return pushAnimator
        case .pop:
            return popAnimator
        default:
            return nil
        }
    }

    func navigationController(
        _ navigationController: UINavigationController,
        interactionControllerFor animationController: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        popInteractionController.isInteracting ? popInteractionController : nil
    }

    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        popInteractionController.attachIfNeeded(to: navigationController)

        guard let trackedViewController else { return }

        if viewController === trackedViewController {
            hasShownTrackedViewController = true
            return
        }

        if hasShownTrackedViewController, navigationController.viewControllers.contains(where: { $0 === trackedViewController }) == false {
            popInteractionController.detach()
            onDidFinishTrackedPop?()
        }
    }
}

@MainActor
private final class NavigationPopInteractionController: UIPercentDrivenInteractiveTransition {
    private weak var navigationController: UINavigationController?
    private var panGesture: UIPanGestureRecognizer?
    private var previousSystemInteractivePopEnabled = true
    private(set) var isInteracting = false

    func attachIfNeeded(to navigationController: UINavigationController) {
        guard self.navigationController !== navigationController else { return }
        detach()
        self.navigationController = navigationController

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.maximumNumberOfTouches = 1
        pan.delegate = self
        navigationController.view.addGestureRecognizer(pan)
        panGesture = pan
        previousSystemInteractivePopEnabled = navigationController.interactivePopGestureRecognizer?.isEnabled ?? true
        navigationController.interactivePopGestureRecognizer?.isEnabled = false
    }

    func detach() {
        if let panGesture {
            panGesture.view?.removeGestureRecognizer(panGesture)
        }
        panGesture = nil
        navigationController?.interactivePopGestureRecognizer?.isEnabled = previousSystemInteractivePopEnabled
        navigationController = nil
        isInteracting = false
    }

    @objc
    private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view, let navigationController else { return }

        let translation = gesture.translation(in: view)
        let progress = max(0.0, min(1.0, translation.x / max(view.bounds.width, 1)))
        let velocityX = gesture.velocity(in: view).x

        switch gesture.state {
        case .began:
            guard navigationController.viewControllers.count > 1 else { return }
            isInteracting = true
            completionCurve = .easeOut
            navigationController.popViewController(animated: true)
        case .changed:
            guard isInteracting else { return }
            update(progress)
        case .ended:
            guard isInteracting else { return }
            isInteracting = false
            let projectedProgress = progress + (velocityX / max(view.bounds.width, 1)) * 0.2
            let shouldFinish = projectedProgress > 0.5 || velocityX > 900
            completionSpeed = shouldFinish ? 0.95 : 0.85
            if shouldFinish {
                finish()
            } else {
                cancel()
            }
        case .cancelled, .failed:
            guard isInteracting else { return }
            isInteracting = false
            completionSpeed = 0.85
            cancel()
        default:
            break
        }
    }
}

extension NavigationPopInteractionController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return false }
        let velocity = pan.velocity(in: pan.view)
        return abs(velocity.x) > abs(velocity.y) && velocity.x > 0
    }
}

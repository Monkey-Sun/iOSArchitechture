import UIKit

@MainActor
public final class FadePushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let duration: TimeInterval

    public init(duration: TimeInterval = 0.28) {
        self.duration = duration
        super.init()
    }

    public func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        duration
    }

    public func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }

        let container = transitionContext.containerView
        toView.alpha = 0.0
        container.addSubview(toView)

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            toView.alpha = 1.0
        }, completion: { finished in
            let cancelled = transitionContext.transitionWasCancelled
            if cancelled {
                toView.removeFromSuperview()
            }
            transitionContext.completeTransition(!cancelled && finished)
        })
    }
}

@MainActor
public final class FadePopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let duration: TimeInterval

    public init(duration: TimeInterval = 0.28) {
        self.duration = duration
        super.init()
    }

    public func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        duration
    }

    public func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        guard
            let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to)
        else {
            transitionContext.completeTransition(false)
            return
        }

        let container = transitionContext.containerView
        let insertedToView = toView.superview == nil
        if toView.superview == nil {
            container.insertSubview(toView, belowSubview: fromView)
        }

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            fromView.alpha = 0.0
        }, completion: { finished in
            let cancelled = transitionContext.transitionWasCancelled
            fromView.alpha = 1.0
            if cancelled, insertedToView {
                toView.removeFromSuperview()
            }
            transitionContext.completeTransition(!cancelled && finished)
        })
    }
}

@MainActor
public final class SlideUpPresentationDelegate: NSObject, UIViewControllerTransitioningDelegate {
    private let presentAnimator = SlideUpPresentAnimator()
    private let dismissAnimator = SlideDownDismissAnimator()
    private let interactionController = PanDismissInteractionController()

    public override init() {}

    public func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> (any UIViewControllerAnimatedTransitioning)? {
        interactionController.attach(to: targetContentViewController(from: presented))
        return presentAnimator
    }

    public func animationController(forDismissed dismissed: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        dismissAnimator
    }

    public func interactionControllerForDismissal(
        using animator: any UIViewControllerAnimatedTransitioning
    ) -> (any UIViewControllerInteractiveTransitioning)? {
        interactionController.isInteracting ? interactionController : nil
    }

    private func targetContentViewController(from presented: UIViewController) -> UIViewController {
        if let nav = presented as? UINavigationController, let root = nav.viewControllers.first {
            return root
        }
        return presented
    }
}

@MainActor
private final class SlideUpPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        0.35
    }

    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        guard
            let toView = transitionContext.view(forKey: .to),
            let toVC = transitionContext.viewController(forKey: .to)
        else {
            transitionContext.completeTransition(false)
            return
        }

        let container = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toVC)
        toView.frame = finalFrame.offsetBy(dx: 0, dy: container.bounds.height)
        container.addSubview(toView)

        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: [.curveEaseOut]) {
            toView.frame = finalFrame
        } completion: { finished in
            transitionContext.completeTransition(finished)
        }
    }
}

@MainActor
private final class SlideDownDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        0.28
    }

    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        guard
            let fromView = transitionContext.view(forKey: .from)
        else {
            transitionContext.completeTransition(false)
            return
        }

        let container = transitionContext.containerView
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: [.curveEaseIn]) {
            fromView.frame = fromView.frame.offsetBy(dx: 0, dy: container.bounds.height)
            fromView.alpha = 0.95
        } completion: { finished in
            transitionContext.completeTransition(finished)
        }
    }
}

@MainActor
private final class PanDismissInteractionController: UIPercentDrivenInteractiveTransition {
    private weak var targetViewController: UIViewController?
    private var panGesture: UIPanGestureRecognizer?
    private(set) var isInteracting = false

    func attach(to viewController: UIViewController) {
        targetViewController = viewController

        if let panGesture {
            viewController.view.removeGestureRecognizer(panGesture)
        }

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.maximumNumberOfTouches = 1
        viewController.view.addGestureRecognizer(pan)
        panGesture = pan
    }

    @objc
    private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }
        let translation = gesture.translation(in: view)
        let progress = max(0.0, min(1.0, translation.y / max(view.bounds.height, 1)))

        switch gesture.state {
        case .began:
            isInteracting = true
            targetViewController?.dismiss(animated: true)
        case .changed:
            update(progress)
        case .ended, .cancelled:
            isInteracting = false
            let velocityY = gesture.velocity(in: view).y
            if progress > 0.35 || velocityY > 900 {
                finish()
            } else {
                cancel()
            }
        default:
            break
        }
    }
}

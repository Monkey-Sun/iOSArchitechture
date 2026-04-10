import UIKit

@MainActor final class PushTransitionProxy: NSObject, UINavigationControllerDelegate {
    let pushAnimator: UIViewControllerAnimatedTransitioning
    let popAnimator: UIViewControllerAnimatedTransitioning?
    weak var previousDelegate: UINavigationControllerDelegate?
    var onDidShow: (() -> Void)?

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
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        onDidShow?()
    }
}

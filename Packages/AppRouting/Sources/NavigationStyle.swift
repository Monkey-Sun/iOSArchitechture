import UIKit

public enum PushTransition {
    case system
    case custom(
        pushAnimator: UIViewControllerAnimatedTransitioning,
        popAnimator: UIViewControllerAnimatedTransitioning? = nil
    )
}

public enum PresentTransition {
    case system
    case custom(
        delegate: UIViewControllerTransitioningDelegate,
        presentationStyle: UIModalPresentationStyle = .custom
    )
}

public enum PresentationStyle {
    case fullScreen
    case pageSheet
    case formSheet
    case custom(UIModalPresentationStyle)

    var uiStyle: UIModalPresentationStyle {
        switch self {
        case .fullScreen:
            return .fullScreen
        case .pageSheet:
            return .pageSheet
        case .formSheet:
            return .formSheet
        case .custom(let style):
            return style
        }
    }
}

public enum NavigationStyle {
    case push(animated: Bool = true, transition: PushTransition = .system)
    case present(
        animated: Bool = true,
        presentation: PresentationStyle = .fullScreen,
        wrapInNavigation: Bool = false,
        transition: PresentTransition = .system
    )
}

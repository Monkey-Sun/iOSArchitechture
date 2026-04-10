import UIKit
import AppRouting

@MainActor
public enum HomeRoute: Routable {
    case home
    case detail(id: String)

    public var navigationStyle: NavigationStyle {
        switch self {
        case .home:
            return .push(animated: false)
        case .detail:
            return .push(
                animated: true,
                transition: .custom(pushAnimator: FadePushAnimator())
            )
        }
    }

    public var requiresAuthentication: Bool {
        switch self {
        case .home:
            return false
        case .detail:
            return true
        }
    }

    public var loginResumePolicy: LoginResumePolicy {
        switch self {
        case .home:
            return .discardInterceptedRoute
        case .detail:
            return .resumeInterceptedRoute
        }
    }
    
    public var associatedModule: String { AppModuleName.home.rawValue }
}

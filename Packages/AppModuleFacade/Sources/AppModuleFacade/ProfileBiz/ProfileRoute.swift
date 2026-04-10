import UIKit
import AppRouting

@MainActor
/// Profile 模块路由集合。
public enum ProfileRoute: Routable {
    case profile(userId: String)
    public var navigationStyle: NavigationStyle {
        .present(
            animated: true,
            presentation: .pageSheet,
            wrapInNavigation: true,
            transition: .custom(
                delegate: SlideUpPresentationDelegate(),
                presentationStyle: .custom
            )
        )
    }

    public var requiresAuthentication: Bool { true }
    
    public var associatedModule: String { AppModuleName.profile.rawValue }
}

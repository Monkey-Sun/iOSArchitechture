import UIKit
import AppRouting

@MainActor
public enum SettingsRoute: Routable {
    case settings
    
    public var navigationStyle: NavigationStyle {
        .present(
            animated: true,
            presentation: .formSheet,
            wrapInNavigation: true
        )
    }

    public var requiresAuthentication: Bool { true }
    
    public var associatedModule: String { AppModuleName.settings.rawValue }
}

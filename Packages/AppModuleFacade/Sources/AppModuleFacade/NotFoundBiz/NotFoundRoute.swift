import UIKit
import AppRouting

@MainActor
public enum UnresolvedRoute: Routable {
    case notFound(originalRouteType: String)
    public var navigationStyle: NavigationStyle {
        .present(animated: true, presentation: .formSheet, wrapInNavigation: true)
    }

    public var requiresAuthentication: Bool { false }
    public var associatedModule: String { AppModuleName.notFound.rawValue }
}

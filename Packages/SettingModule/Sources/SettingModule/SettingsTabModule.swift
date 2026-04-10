import UIKit
import AppModuleFacade
import AppRouting

@MainActor
/// Settings Tab 的模块入口：负责将 `SettingsRoute` 映射为设置页。
public final class SettingsTabModule: TabModuleProviding {
    public func registerRouteHandlers(name: String, into resolver: AppModuleBootstrap) {
        resolver.append(moduleName: moduleName) { route, routing in
            return SettingsViewController(routing: routing)
        }
    }
    
    public let tabIndex: Int = AppModuleName.settings.tabIndex
    public let tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), tag: AppModuleName.settings.tabIndex)
    public let navigationController = UINavigationController()

    public init() {}
    public func initialRoute() -> Routable { SettingsRoute.settings }
    
    public var moduleName: String { AppModuleName.settings.rawValue }
}

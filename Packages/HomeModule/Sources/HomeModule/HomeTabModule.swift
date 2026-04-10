import UIKit
import AppModuleFacade
import AppRouting

@MainActor
/// Home Tab 的模块入口：负责将 `HomeRoute` 映射为对应页面。
public final class HomeTabModule: TabModuleProviding {
    public var moduleName: String { AppModuleName.home.rawValue }
    
    public func registerRouteHandlers(name: String, into resolver: AppModuleBootstrap) {
        resolver.append(moduleName: moduleName) { route, routing in
            guard let home = route as? HomeRoute else { return nil }
            switch home {
            case .home:
                return HomeViewController(routing: routing)
            case .detail(let id):
                return DetailViewController(routing: routing, itemId: id)
            }
        }
    }
    
    public let tabIndex: Int = AppModuleName.home.tabIndex
    public let tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: AppModuleName.home.tabIndex)
    public let navigationController = UINavigationController()

    public init() {}

    public func initialRoute() -> Routable { HomeRoute.home }
}

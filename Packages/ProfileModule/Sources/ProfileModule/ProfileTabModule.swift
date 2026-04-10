import UIKit
import AppModuleFacade
import AppRouting

@MainActor
/// Profile Tab 的模块入口：负责将 `ProfileRoute` 映射为对应页面。
public final class ProfileTabModule: TabModuleProviding {
    public var moduleName: String { AppModuleName.profile.rawValue }
    
    public func registerRouteHandlers(name: String, into resolver: AppModuleBootstrap) {
        resolver.append(moduleName: moduleName) { route, routing in
            guard let profile = route as? ProfileRoute else { return nil }
            switch profile {
            case .profile(let userId):
                return ProfileViewController(userId: userId, routing: routing)
            }
        }
    }
    
    public let tabIndex: Int = AppModuleName.profile.tabIndex
    public let tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: AppModuleName.profile.tabIndex)
    public let navigationController = UINavigationController()

    public init() {}

    
    public func initialRoute() -> Routable { ProfileRoute.profile(userId: "u_1001") }
}

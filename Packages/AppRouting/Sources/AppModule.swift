import UIKit

/// 不占用 Tab 的独立模块：界面仅通过 `Route` 按需呈现。
/// 由 `AppCoordinator` 在装配阶段调用 `registerRouteHandlers(into:)` 注册视图解析。
@MainActor public protocol AppModuleProviding: AnyObject {
    // 模块名称
    var moduleName: String { get }
    // 注册模块中的路由跳转逻辑
    func registerRouteHandlers(name: String, into resolver: AppModuleBootstrap)
}

/// App 的Tab模块
@MainActor public protocol TabModuleProviding: AppModuleProviding {
    var tabIndex: Int { get }
    var tabBarItem: UITabBarItem { get }
    var navigationController: UINavigationController { get }
    func initialRoute() -> Routable
}

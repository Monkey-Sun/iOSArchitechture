import UIKit

/// 未登录拦截某次导航后，登录成功是否自动继续该次导航。
public enum LoginResumePolicy: Sendable {
    /// 登录成功后自动执行被拦截的那次 `route`。
    case resumeInterceptedRoute
    /// 登录成功后不自动继续；被拦截的目标不会自动打开。
    case discardInterceptedRoute
}

@MainActor
/// 可被 `AppRoutable` 处理的路由抽象。
///
/// 按 Apple 命名惯例，协议名使用 `-able` 以表达“可路由”的能力。
public protocol Routable {
    var navigationStyle: NavigationStyle { get }
    var requiresAuthentication: Bool { get }
    var loginResumePolicy: LoginResumePolicy { get }
    /// 声明该路由归属哪个模块（用于 Tab 选择与 resolver 查找）。
    var associatedModule: String { get }
}

public extension Routable {
    var requiresAuthentication: Bool { false }
    var loginResumePolicy: LoginResumePolicy { .resumeInterceptedRoute }
}


@MainActor public final class TabRouter {
    private weak var tabBarController: UITabBarController?
    private var navMap: [Int: UINavigationController]

    public init(tabBarController: UITabBarController, navMap: [Int: UINavigationController]) {
        self.tabBarController = tabBarController
        self.navMap = navMap
    }

    public func select(_ tabIndex: Int) {
        tabBarController?.selectedIndex = tabIndex
    }

    public func navigationController(for tabIndex: Int) -> UINavigationController? {
        navMap[tabIndex]
    }
}


import UIKit

typealias RouteResolver = (Routable, AppRoutable) -> UIViewController?

/// 将 `Route` 解析为具体 `UIViewController`；由组合根注册各 feature 的 handler，替代 Route 枚举上的静态工厂。
@MainActor public protocol RouteViewResolving: AnyObject {
    func makeViewController(for route: Routable, routing: AppRoutable) -> UIViewController
}

/// 按注册顺序依次尝试 handler，第一个返回非 `nil` 的胜出。
@MainActor
public final class AppModuleBootstrap: RouteViewResolving {
    private var handlers: [String: RouteResolver] = [:]
    private var unresolvedRouteFallback: ((Routable) -> Routable?)?
    
    public init() {}
    
    public func append(moduleName: String, _ handler: @escaping (Routable, AppRoutable) -> UIViewController?) {
        if handlers[moduleName] != nil {
            assertionFailure("Duplicate RouteViewResolver handler registration for module: \(moduleName)")
            return
        }
        handlers[moduleName] = handler
    }
    
    /// 配置“路由未命中”时的统一回退路由（例如业务注入的 404 路由）。
    public func setUnresolvedRouteFallback(_ fallback: @escaping (Routable) -> Routable?) {
        unresolvedRouteFallback = fallback
    }
    
    public func makeViewController(for route: Routable, routing: AppRoutable) -> UIViewController {
        if let handler = handlers[route.associatedModule], let vc = handler(route, routing) {
            return vc
        }
        if let fallbackRoute = unresolvedRouteFallback?(route),
           fallbackRoute.associatedModule != route.associatedModule,
           let fallbackHandler = handlers[fallbackRoute.associatedModule],
           let fallbackVC = fallbackHandler(fallbackRoute, routing) {
            return fallbackVC
        }
        assertionFailure("No RouteViewResolver handler matched route type: \(Swift.type(of: route))")
        return UIViewController()
    }
}

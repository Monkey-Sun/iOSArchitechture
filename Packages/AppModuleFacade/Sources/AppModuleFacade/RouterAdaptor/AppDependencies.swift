import AppRouting

/// 组合根注入的可替换依赖；随功能扩展在此增加字段即可。
public struct AppDependencies {
    public let authSession: AuthenticationSessionManaging
    public let deepLinkRouter: DeepLinkRouting
    public let notFoundRouteFactory: @MainActor (Routable) -> Routable?

    public init(
        authSession: AuthenticationSessionManaging,
        deepLinkRouter: DeepLinkRouting,
        notFoundRouteFactory: @escaping @MainActor (Routable) -> Routable? = { _ in nil }
    ) {
        self.authSession = authSession
        self.deepLinkRouter = deepLinkRouter
        self.notFoundRouteFactory = notFoundRouteFactory
    }
}

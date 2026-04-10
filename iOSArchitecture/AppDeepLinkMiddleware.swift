import Foundation
import AppModuleFacade

/// App 层 DeepLink：白名单校验 + 路由表映射（path → `Route` + query 解码）。
@MainActor
struct AppDeepLinkMiddleware: DeepLinkRouting {
    private static let allowlist = DeepLinkAllowlist(
        schemes: ["myapp"],
        hosts: ["app"]
    )

    func route(for url: URL) -> Routable? {
        guard let context = DeepLinkParser.parse(url: url, allowlist: Self.allowlist) else {
            return nil
        }
        return AppDeepLinkRouteTable.resolve(context)
    }
}

private enum AppDeepLinkRouteTable {
    static func resolve(_ context: DeepLinkContext) -> Routable? {
        guard let head = context.pathSegments.first else { return nil }
        switch head {
        case "home":
            return HomeRoute.home
        case "settings":
            return SettingsRoute.settings
        case "detail":
            guard let id = context.query["id"] else { return nil }
            return HomeRoute.detail(id: id)
        case "profile":
            guard let userId = context.query["userId"] else { return nil }
            return ProfileRoute.profile(userId: userId)
        default:
            return nil
        }
    }
}

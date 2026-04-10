import Foundation

/// DeepLink 白名单：校验 scheme / host，避免任意 URL 误触发应用内路由。
public struct DeepLinkAllowlist: Sendable {
    public var schemes: Set<String>
    /// 为空则接受任意 host（仍会校验 scheme）。
    public var hosts: Set<String>

    public init(schemes: Set<String>, hosts: Set<String> = []) {
        self.schemes = schemes
        self.hosts = hosts
    }
}

/// 解析后的路径与查询参数，供路由表映射为 `Route`。
public struct DeepLinkContext: Sendable {
    public let pathSegments: [String]
    public let query: [String: String]
}

public enum DeepLinkParser {
    public static func parse(url: URL, allowlist: DeepLinkAllowlist) -> DeepLinkContext? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }
        let scheme = (components.scheme ?? "").lowercased()
        guard allowlist.schemes.contains(scheme) else { return nil }

        let host = (components.host ?? "").lowercased()
        if !allowlist.hosts.isEmpty, !allowlist.hosts.contains(host) {
            return nil
        }

        let trimmed = components.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let segments = trimmed.isEmpty ? [] : trimmed.split(separator: "/").map(String.init)

        var query: [String: String] = [:]
        components.queryItems?.forEach { item in
            if let value = item.value {
                query[item.name] = value
            }
        }

        return DeepLinkContext(pathSegments: segments, query: query)
    }
}

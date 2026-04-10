import AppRouting

@MainActor
/// 一个最小可用的 `AuthSession` 实现，用于 Demo / 开发阶段。
///
/// - Note: 该实现仅保存在内存中；应用重启后状态会丢失。生产环境中可替换为 Keychain/服务端会话等实现。
public final class InMemoryAuthSession: AuthenticationSessionManaging {
    public private(set) var isAuthenticated: Bool = false

    public init() {}

    public func markAuthenticated() {
        isAuthenticated = true
    }

    public func markLoggedOut() {
        isAuthenticated = false
    }
}


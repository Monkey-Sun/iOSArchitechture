import UIKit

@MainActor public protocol Coordinating: AnyObject {
    func start()
}

@MainActor public protocol AuthenticationStatusProviding {
    var isAuthenticated: Bool { get }
}

@MainActor public protocol AuthenticationSessionManaging: AuthenticationStatusProviding {
    func markAuthenticated()
    func markLoggedOut()
}

@MainActor public protocol AppRoutable: AnyObject {
    func route(_ route: Routable, from source: UIViewController?)
    /// - Parameter source: 用户操作时所在的控制器；传入后 Modal 会优先从该控制器弹出，避免从未选中的 Tab 的导航栈上 present 导致 “detached” 警告。
    func handleDeepLink(_ url: URL, from source: UIViewController?)
    func pop(from source: UIViewController?, animated: Bool)
    func popToRoot(in tabIndex: Int?, animated: Bool)
    func replaceRoot(with route: Routable, embedInNavigation: Bool)
}

extension AppRoutable {
    public func handleDeepLink(_ url: URL) {
        handleDeepLink(url, from: nil)
    }
}

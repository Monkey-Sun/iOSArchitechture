import Testing
import UIKit
@testable import HomeModule
@testable import AppModuleFacade

@MainActor
@Test func homeTabModuleRegistersHomeRouteHandler() {
    let resolver = AppModuleBootstrap()
    let module = HomeTabModule()
    module.registerRouteHandlers(name: module.moduleName, into: resolver)
    let routing = MockAppRouting()
    let vc = resolver.makeViewController(for: HomeRoute.home, routing: routing)
    #expect(vc is HomeViewController)
}

private final class MockAppRouting: AppRoutable {
    func route(_ route: Routable, from source: UIViewController?) {}
    func handleDeepLink(_ url: URL, from source: UIViewController?) {}
    func pop(from source: UIViewController?, animated: Bool) {}
    func popToRoot(in tabIndex: Int?, animated: Bool) {}
    func replaceRoot(with route: Routable, embedInNavigation: Bool) {}
}

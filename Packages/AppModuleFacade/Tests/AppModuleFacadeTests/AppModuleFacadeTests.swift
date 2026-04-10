import Testing
import UIKit
@testable import AppModuleFacade
import AppRouting

@MainActor
@Test func compositeRouteViewResolverSkipsNilThenMatches() {
    let resolver = AppModuleBootstrap()
    var matched = false
    resolver.append(moduleName: .settings) { _, _ in nil }
    resolver.append(moduleName: .home) { route, _ in
        guard route as? HomeRoute != nil else { return nil }
        matched = true
        return UIViewController()
    }
    _ = resolver.makeViewController(for: HomeRoute.home, routing: nil)
    #expect(matched)
}

@MainActor
@Test func routeResolverDuplicateRegistrationKeepsFirstHandler() {
    let resolver = AppModuleBootstrap()
    let marker = UIViewController()

    resolver.append(moduleName: .home) { _, _ in
        marker
    }
    resolver.append(moduleName: .home) { _, _ in
        UIViewController()
    }

    let resolved = resolver.makeViewController(for: HomeRoute.home, routing: nil)
    #expect(resolved === marker)
}

@MainActor
@Test func appDependenciesHoldsSessionAndDeepLink() {
    let auth = InMemoryAuthSession()
    let deepLink = MockDeepLinkRouter()
    let deps = AppDependencies(authSession: auth, deepLinkRouter: deepLink)
    #expect(deps.authSession === auth)
    #expect((deps.deepLinkRouter as AnyObject) === deepLink)
}

@MainActor
private final class MockDeepLinkRouter: DeepLinkRouting {
    func route(for url: URL) -> Routable? { nil }
}

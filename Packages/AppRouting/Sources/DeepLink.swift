import Foundation

@MainActor public protocol DeepLinkRouting {
    func route(for url: URL) -> Routable?
}

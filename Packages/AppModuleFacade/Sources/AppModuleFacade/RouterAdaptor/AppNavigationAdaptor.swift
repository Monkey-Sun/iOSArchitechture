import UIKit
import AppRouting

/// 应用壳层入口：组合 `AppCoordinator` 并对外暴露 `AppNavigationHost`，供构造注入到各页面。
@MainActor
public final class AppNavigationAdaptor {
    private let coordinator: AppCoordinator
    // tabs APP底部的Tab
    // appModules APP内独立的业务模块
    public init(
        window: UIWindow,
        tabs: [TabModuleProviding],
        appModules: [AppModuleProviding],
        dependencies: AppDependencies,
    ) {
        self.coordinator = AppCoordinator(
            window: window,
            tabs: tabs,
            appModules: appModules,
            dependencies: dependencies,
        )
    }

    public func start() {
        coordinator.start()
    }

    /// 应用内导航、DeepLink 与跨模块能力的统一入口，优先注入到 ViewController。
    public var routing: AppRoutable { coordinator }
}

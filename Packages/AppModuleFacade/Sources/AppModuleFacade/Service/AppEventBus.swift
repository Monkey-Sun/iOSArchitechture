//
//  File.swift
//  AppModuleFacade
//
//  Created by 孙俊祥 on 2026/4/13.
//

import Foundation

/// 事件总线载荷类型标记（用法类似 Flutter `package:event_bus` 里的事件类）。
public protocol AppBusEvent: Sendable {}

/// 订阅句柄：在 **最后一个强引用释放** 时（例如持有者 `deinit`）会自动从总线移除，一般无需再调 `remove`。
/// - Note: 需要订阅持续生效时，必须把本句柄存成属性（或交给更长生命周期的对象持有）；若像 `on { }` 一样不保存返回值，订阅会在当前语句结束后立刻取消。
public final class AppEventSubscription: Hashable {
    public let id: UUID
    nonisolated(unsafe) private weak var bus: AppEventBus?

    fileprivate init(id: UUID, bus: AppEventBus) {
        self.id = id
        self.bus = bus
    }

    deinit {
        let id = id
        Task { @MainActor [weak bus] in
            bus?.remove(id)
        }
    }

    /// 立即取消订阅（仍在 MainActor 上派发回调时，可在回调末尾调用以避免异步 `deinit` 前重复收到事件）。
    @MainActor
    public func cancel() {
        bus?.remove(id)
    }

    public static func == (lhs: AppEventSubscription, rhs: AppEventSubscription) -> Bool {
        lhs === rhs
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

private struct TypedHandler {
    let id: UUID
    let invoke: @MainActor (Any) -> Void
}

/// 应用内事件总线：在 **MainActor** 上订阅与派发。
/// 订阅时通过闭包参数类型指定 `Event`（类似 `eventBus.on<MyEvent>().listen(...)`）。
@MainActor
public final class AppEventBus {
    public init() {}

    private var handlers: [ObjectIdentifier: [TypedHandler]] = [:]
    private var subscriptionTypeByID: [UUID: ObjectIdentifier] = [:]

    /// 订阅指定类型事件。返回的 `AppEventSubscription` 需在订阅存活期内 **强引用**（例如存为属性）；
    /// 不保存返回值时订阅会随临时句柄释放而立刻取消。
    @discardableResult
    public func on<Event: AppBusEvent>(
        _ handler: @escaping @MainActor (Event) -> Void
    ) -> AppEventSubscription {
        let id = UUID()
        let key = ObjectIdentifier(Event.self)
        let typed = TypedHandler(id: id) { payload in
            guard let event = payload as? Event else { return }
            handler(event)
        }
        handlers[key, default: []].append(typed)
        subscriptionTypeByID[id] = key
        return AppEventSubscription(id: id, bus: self)
    }

    public func remove(_ subscription: AppEventSubscription) {
        remove(subscription.id)
    }

    public func remove(_ id: UUID) {
        guard let key = subscriptionTypeByID.removeValue(forKey: id) else { return }
        handlers[key]?.removeAll { $0.id == id }
        if handlers[key]?.isEmpty == true {
            handlers.removeValue(forKey: key)
        }
    }

    /// 派发事件，仅唤醒订阅了该 `Event` 类型的监听者。
    public func post<Event: AppBusEvent>(_ event: Event) {
        let key = ObjectIdentifier(Event.self)
        let snapshot = handlers[key] ?? []
        for item in snapshot {
            item.invoke(event)
        }
    }
}

//
//  File.swift
//  AppModuleFacade
//
//  Created by 孙俊祥 on 2026/4/13.
//

import Foundation

/// 事件总线载荷类型标记（用法类似 Flutter `package:event_bus` 里的事件类）。
public protocol AppBusEvent: Sendable {}

/// 订阅句柄，用于 `remove`。
@MainActor
public struct AppEventSubscription: Hashable, Sendable {
    public let id: UUID

    fileprivate init(id: UUID) {
        self.id = id
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

    /// `on` 的别名。
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
        return AppEventSubscription(id: id)
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

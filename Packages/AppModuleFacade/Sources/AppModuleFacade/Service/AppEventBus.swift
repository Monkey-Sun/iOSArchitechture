//
//  File.swift
//  AppModuleFacade
//
//  Created by 孙俊祥 on 2026/4/13.
//

import Foundation

public class AppEventHandler<T, E>: Identifiable {
    public let id = UUID() // 用于移除监听时的对比
    public let handler: (T) -> E // 真正的处理逻辑
    
    public init(handler: @escaping (T) -> E) {
        self.handler = handler
    }
}

public class AppEventBus<T, E> {
    public init() {}
    private let lock = NSLock()
    private var obxList = [AppEventHandler<T, E>]()
    
    /// 添加监听
    public func add(_ obs: AppEventHandler<T, E>) {
        lock.lock()
        defer { lock.unlock() }
        obxList.append(obs)
    }
    
    /// 移除监听
    public func remove(_ obs: AppEventHandler<T, E>) {
        lock.lock()
        defer { lock.unlock() }
        obxList.removeAll(where: { $0.id == obs.id })
    }
    
    /// 触发事件
    /// - Parameter data: 传入的输入数据
    /// - Returns: 收集到的所有处理结果
    @discardableResult
    public func fire(_ data: T) -> [E] {
        lock.lock()
        let handlers = obxList // 快照，避免执行闭包时死锁
        lock.unlock()
        
        // 执行所有订阅者的闭包并返回结果
        return handlers.map { item in
            item.handler(data)
        }
    }
}

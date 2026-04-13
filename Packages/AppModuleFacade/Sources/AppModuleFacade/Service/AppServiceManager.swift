//
//  File.swift
//  AppModuleFacade
//
//  Created by 孙俊祥 on 2026/4/13.
//

import Foundation

public final class AppService: @unchecked Sendable {
    private static let shared = AppService()
    
    private var services: [String: Any] = [:]
    // 使用锁来保证线程安全
    private let lock = NSRecursiveLock()
    
    private init() {}
    
    public static func register<T>(_ type: T.Type, _ instance: T) {
        Self.shared.lock.withLock {
            let key = "\(type)"
            Self.shared.services[key] = instance
        }
    }
    
    public static func resolve<T>(_ type: T.Type) -> T? {
        Self.shared.lock.withLock {
            let key = "\(type)"
            return Self.shared.services[key] as? T
        }
    }
}

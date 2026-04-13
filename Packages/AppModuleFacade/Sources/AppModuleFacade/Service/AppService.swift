//
//  File.swift
//  AppModuleFacade
//
//  Created by 孙俊祥 on 2026/4/13.
//

import Foundation

public final class AppService {
    @MainActor private static let shared = AppService()
    private var services: [String: Any] = [:]
    private init() {}
    
    @MainActor public static func register<T>(_ type: T.Type, _ instance: T) {
        let key = "\(type)"
        Self.shared.services[key] = instance
    }
    
    @MainActor public static func unRegister<T>(_ type: T.Type) {
        let key = "\(type)"
        Self.shared.services.removeValue(forKey: key)
    }
    
    @MainActor public static func resolve<T>(_ type: T.Type) -> T? {
        let key = "\(type)"
        return Self.shared.services[key] as? T
    }
}

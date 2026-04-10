//
//  File.swift
//  AppModuleFacade
//
//  Created by 孙俊祥 on 2026/4/10.
//

import Foundation

public enum AppModuleName: String {
    case home
    case settings
    case profile
    case login
    case notFound
    public var tabIndex: Int {
        switch self {
        case .home:
            0
        case .settings:
            1
        case .profile:
            2
        default:
            fatalError("不是底部Tab Module")
        }
    }
}

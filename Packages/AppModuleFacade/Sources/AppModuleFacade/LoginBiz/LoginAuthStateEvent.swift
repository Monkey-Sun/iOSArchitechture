//
//  LoginAuthStateEvent.swift
//  AppModuleFacade
//
//  Created by 孙俊祥 on 2026/4/13.
//

import Foundation

public struct LoginAuthStateEvent: AppBusEvent {
    public let isLoggedIn: Bool

    public init(isLoggedIn: Bool) {
        self.isLoggedIn = isLoggedIn
    }
}

public struct RefreshEvent: AppBusEvent {
    public init() {
    }
}

//
//  File.swift
//  LoginModule
//
//  Created by 孙俊祥 on 2026/4/13.
//

import Foundation
import AppModuleFacade

public class LoginService: @MainActor ILoginService {
    let loginBus = AppEventBus<Bool, Void>()
    public init() {}
    @MainActor
    public func toLogin() {
        AppService.resolve(AppRoutable.self)?.route(LoginRoute.login, from: nil)
    }
    
    public var loginEventBus: AppEventBus<Bool, Void> { loginBus }
    
    
    public var serviceName: String { "LoginService" }
}

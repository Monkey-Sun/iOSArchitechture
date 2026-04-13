//
//  File.swift
//  LoginModule
//
//  Created by 孙俊祥 on 2026/4/13.
//

import Foundation
import AppModuleFacade

public class LoginService: @MainActor ILoginService {
    public func logout() {
        print("logout")
        self.loginBus.post(LoginAuthStateEvent(isLoggedIn: false))
    }
    
    let loginBus = AppEventBus()
    
    public init() {}
    
    @MainActor
    public func toLogin() {
        AppService.resolve(AppRoutable.self)?.route(LoginRoute.login, from: nil)
    }
    
    public var loginEventBus: AppEventBus { loginBus }
    
    
    public var serviceName: String { "LoginService" }
    
    public var userInfo: [String : Any] { ["userName": "孙俊祥", "sex": 1] }
}

//
//  File.swift
//  AppModuleFacade
//
//  Created by 孙俊祥 on 2026/4/13.
//

import Foundation

public protocol ILoginService: AppServiceProtocol {
    func toLogin()
    
    func logout()
    
    var loginEventBus: AppEventBus { get }
    
    var userInfo: [String : Any] { get }
}

//
//  File.swift
//  LoginModule
//
//  Created by 孙俊祥 on 2026/4/9.
//

import AppModuleFacade

@MainActor
public final class LoginModule: AppModuleProviding {
    public init() {}

    public func registerRouteHandlers(name: String, into resolver: AppModuleBootstrap) {
        resolver.append(moduleName: moduleName) { route, routing in
            switch route {
            case LoginRoute.login(let cb):
                let vc = LoginViewController(call: cb, routing: routing)
                vc.routing = routing
                return nil
            default:
                return nil
            }
        }
    }
    
    public var moduleName: String { AppModuleName.login.rawValue }
}

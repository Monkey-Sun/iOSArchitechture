//
//  File.swift
//  AppModuleFacade
//
//  Created by 孙俊祥 on 2026/4/9.
//

import UIKit
import AppRouting



@MainActor
public enum LoginRoute: Routable {
    
    case login

    public var navigationStyle: NavigationStyle {
        .present(
            animated: true,
            presentation: .formSheet,
            wrapInNavigation: true
        )
    }

    public var requiresAuthentication: Bool { false }
    
    public var associatedModule: String { AppModuleName.login.rawValue }
}

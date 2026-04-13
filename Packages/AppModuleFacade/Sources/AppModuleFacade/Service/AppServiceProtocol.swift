//
//  File.swift
//  AppModuleFacade
//
//  Created by 孙俊祥 on 2026/4/13.
//

import Foundation

public protocol AppServiceProtocol {
    var serviceName: String { get }
}

extension AppServiceProtocol {
    var serviceName: String { "" }
}

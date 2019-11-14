//
//  ErrorHandler.swift
//  Common
//
//  Created by lpylypenko on 06.06.19.
//  Copyright © 2019 lpylypenko. All rights reserved.
//

import Foundation

public protocol ErrorHandler: class {
    func displayWarning(message: String, autoDismiss: Bool)
    func displayWarning(_ warning: Error, autoDismiss: Bool)
    func displayWarnings(_ warnings: [Error], autoDismiss: Bool)
    func displayError(_ error: Error, precedence: Bool)
    func displayError(message: String, precedence: Bool)
    func displayMessage(_ message: String, precedence: Bool)
    func hideAllMessages()
}

public extension ErrorHandler {
    
    func displayWarning(message: String) {
        displayWarning(message: message, autoDismiss: false)
    }
    
    func displayWarning(_ warning: Error) {
        displayWarning(warning, autoDismiss: false)
    }
    
    func displayWarnings(_ warnings: [Error]) {
        displayWarnings(warnings, autoDismiss: false)
    }
    
    func displayError(_ error: Error) {
        displayError(error, precedence: false)
    }
    
    func displayError(message: String) {
        displayError(message: message, precedence: false)
    }
    
    func displayMessage(_ message: String) {
        displayMessage(message, precedence: false)
    }
}

//
//  ZebraError.swift
//  ZebraScanner
//
//  Created by Andreas Hilbert on 24.10.19.
//  Copyright © 2019 Andreas Hilbert. All rights reserved.
//

import Foundation

enum ZebraError: LocalizedError {
    case statusError(error: SBT_RESULT)
    
    var errorDescription: String? {
        switch self {
        case .statusError(let error):
            return error.message()
        }
    }
}

extension SBT_RESULT {
    func message() -> String {
        var errText: String = ""
        switch self {
        case SBT_RESULT_SUCCESS:
            errText = "SBT_RESULT_SUCCESS"
        case SBT_RESULT_FAILURE:
            errText = "SBT_RESULT_FAILURE"
        case SBT_RESULT_SCANNER_NOT_AVAILABLE:
            errText = "SBT_RESULT_SCANNER_NOT_AVAILABLE"
        case SBT_RESULT_SCANNER_NOT_ACTIVE:
            errText = "SBT_RESULT_SCANNER_NOT_ACTIVE"
        case SBT_RESULT_INVALID_PARAMS:
            errText = "SBT_RESULT_INVALID_PARAMS"
        case SBT_RESULT_RESPONSE_TIMEOUT:
            errText = "SBT_RESULT_RESPONSE_TIMEOUT"
        case SBT_RESULT_OPCODE_NOT_SUPPORTED:
            errText = "SBT_RESULT_OPCODE_NOT_SUPPORTED"
        case SBT_RESULT_SCANNER_NO_SUPPORT:
            errText = "SBT_RESULT_SCANNER_NO_SUPPORT"
        case SBT_RESULT_BTADDRESS_NOT_SET:
            errText = "SBT_RESULT_BTADDRESS_NOT_SET"
        case SBT_RESULT_SCANNER_NOT_CONNECT_STC:
            errText = "SBT_RESULT_SCANNER_NOT_CONNECT_STC"
        default:
            errText = String(format:"%d", self.rawValue)
        }
        return errText
    }
}

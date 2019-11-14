//
//  String+Localizable.swift
//  Common
//
//  Created by lpylypenko on 27.05.19.
//  Copyright © 2019 lpylypenko. All rights reserved.
//

import Foundation

extension String: Localizable {
    
    public func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}

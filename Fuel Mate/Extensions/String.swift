//
//  String.swift
//  Fuel Mate
//
//  Created by Shahla Almasri Hafez on 4/14/18.
//  Copyright © 2018 RZ Solutions. All rights reserved.
//

import Foundation

extension String {
    var isDouble: Bool {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.allowsFloats = true
        let decimalSeparator = formatter.decimalSeparator ?? "."
        
        if formatter.number(from: self) != nil {
            let split = components(separatedBy: decimalSeparator)
            let digits = split.count == 2 ? split.last ?? "" : ""
            return digits.count <= 2
        }
        
        return false
    }
    
    var isYear: Bool {
        let number = Int(self)
        return number != nil && count <= 4
    }
}

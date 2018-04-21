//
//  Double.swift
//  Fuel Mate
//
//  Created by Shahla Almasri Hafez on 4/13/18.
//  Copyright © 2018 RZ Solutions. All rights reserved.
//

import Foundation

extension Double {
    var displayName: String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        return currencyFormatter.string(from: NSNumber(value: self))!
    }
}

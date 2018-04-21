//
//  UIDate.swift
//  Fuel Mate
//
//  Created by Shahla Almasri Hafez on 4/13/18.
//  Copyright © 2018 RZ Solutions. All rights reserved.
//

import Foundation

extension Date {
    var string: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: self)
    }
}

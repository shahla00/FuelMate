//
//  ExpenseCell.swift
//  Fuel Mate
//
//  Created by Shahla Almasri Hafez on 4/13/18.
//  Copyright © 2018 RZ Solutions. All rights reserved.
//

import UIKit
import CoreData

///
///
///
class ExpenseCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var litresLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var vehicleLabel: UILabel!

    ///
    /// Shows the given expense details in the cell's labels.
    ///
    func configureCell(expense: Expense) {
        dateLabel.text = "Date: \(expense.expDate?.string ?? "")"
        litresLabel.text = "Litres: \(String(expense.expLitre))"
        locationLabel.text = "Location: \(expense.location ?? "")"
        amountLabel.text = "Amount: \(expense.expAmount.displayName)"
        
        if let vehicle = expense.vehicle, let brand = vehicle.brand, let model = vehicle.model {
            vehicleLabel.text = "Vehicle: \(brand) \(model) \(vehicle.year), capacity: \(vehicle.capacity)"
        }
    }
}

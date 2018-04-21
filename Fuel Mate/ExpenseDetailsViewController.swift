//
//  ExpenseDetailsViewController.swift
//  Fuel Mate
//
//  Created by Shahla Almasri Hafez on 4/13/18.
//  Copyright © 2018 RZ Solutions. All rights reserved.
//

import UIKit

protocol AddExpenseDelegate {
    func didAddExpense()
}

protocol EditExpenseDelegate {
    func didEditExpense(at itemIndex: Int)
}

///
/// This view controller is used for both adding a new expense, and editing an existing one.
///
class ExpenseDetailsViewController: UIViewController {
    @IBOutlet weak var litres: UITextField!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var date: UITextField!
    
    @IBOutlet weak var brand: UITextField!
    @IBOutlet weak var model: UITextField!
    @IBOutlet weak var year: UITextField!
    @IBOutlet weak var capacity: UITextField!
    
    var addDelegate: AddExpenseDelegate? = nil
    var editDelegate: EditExpenseDelegate? = nil
    var index: Int = -1
    
    let datePicker = UIDatePicker()
    
    ///
    ///
    ///
    var expense: Expense? {
        didSet {
            if let expense = expense {
                litres.text = String(expense.expLitre)
                location.text = expense.location
                amount.text = String(expense.expAmount)
                date.text = expense.expDate?.string
                
                // Default the date picker to the expense's date
                if let date = expense.expDate {
                    datePicker.date = date
                }
                
                brand.text = expense.vehicle?.brand
                model.text = expense.vehicle?.model
                year.text = String(expense.vehicle?.year ?? 0)
                capacity.text = String(expense.vehicle?.capacity ?? 0)
            } else {
                litres.text = ""
                location.text = ""
                amount.text = ""
                date.text = ""
            }
        }
    }
    
    ///
    //
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the date picker
        datePicker.datePickerMode = .date
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done",
                                         style: .plain,
                                         target: self,
                                         action: #selector(doneDatePickerTapped));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePickerTapped));
        
        toolbar.setItems([doneButton, spaceButton, cancelButton], animated: false)
        
        date.inputAccessoryView = toolbar
        date.inputView = datePicker
        
        date.delegate = self
        amount.delegate = self
        litres.delegate = self
        capacity.delegate = self
        year.delegate = self
    }
    
    ///
    /// Callback for when the back button is tapped.
    ///
    @IBAction func didTapBackButton() {
        dismissDetail()
    }

    ///
    /// Call back for when the save button is tapped.
    ///
    @IBAction func didTapSaveButton() {
        if litres.text == "" || location.text == "" || amount.text == "" || date.text == "" {
            showAlert(title: "Error", message: "Amount, date, litre, and location felds cannot be empty")
        } else if brand.text == "" || model.text == "" || year.text == "" || capacity.text == ""{
            showAlert(title: "Error", message: "Brand, model, year, and capacity felds cannot be empty")
        } else {
            saveExpense() { (complete) in
                if complete {
                    addDelegate?.didAddExpense()
                    editDelegate?.didEditExpense(at: index)
                    dismiss(animated: true, completion: nil)
                } else {
                    showAlert(title: "Error", message: "Failed to save to the database")
                }
            }
        }
    }
    
    ///
    /// Callback for when the Done button in the date picker is tapped.
    ///
    @objc func doneDatePickerTapped() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        date.text = formatter.string(from: datePicker.date)
        view.endEditing(true)
    }
    
    ///
    /// Callback for when the Cancel button in the date picker is tapped.
    ///
    @objc func cancelDatePickerTapped() {
        view.endEditing(true)
    }
    
    ///
    /// Saves the new expense to the database.
    ///
    func saveExpense(completion: (_ succeeded: Bool) -> ()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        let litres = Double(self.litres.text!)!
        let amount = Double(self.amount.text!)!
        let location = self.location.text
        let brand = self.brand.text
        let model = self.model.text
        let year = Int16(self.year.text!)!
        let capacity = Float(self.capacity.text!)!
        
        if expense == nil {
            expense = Expense(context: managedContext)
            expense?.vehicle = Vehicle(context: managedContext)
        }
        
        expense?.expLitre = litres
        expense?.location = location
        expense?.expAmount = amount
        expense?.expDate = datePicker.date
        expense?.uuid = UUID()
        
        expense?.vehicle?.brand = brand
        expense?.vehicle?.model = model
        expense?.vehicle?.year = year
        expense?.vehicle?.capacity = capacity
        expense?.vehicle?.uuid = UUID()
        
        do {
            try managedContext.save()
            completion(true)
        } catch {
            completion(false)
        }
    }
}

extension ExpenseDetailsViewController: UITextFieldDelegate {
    ///
    ///
    ///
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == date {
            // The user should not be able to type in in the date field
            textField.text = ""
            return false
        } else if textField == amount || textField == litres || textField == capacity {
            // The user should be allowed to type in decimal numbers only, respecting locale.
            if string.isEmpty { return true }
            let text = textField.text ?? ""
            let replacementText = (text as NSString).replacingCharacters(in: range, with: string)
            return replacementText.isDouble
        } else if textField == year {
            return string.isYear
        }
        return true
    }
}

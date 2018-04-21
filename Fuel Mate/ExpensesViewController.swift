//
//  ViewController.swift
//  Fuel Mate
//
//  Created by Shahla Almasri Hafez on 4/13/18.
//  Copyright © 2018 RZ Solutions. All rights reserved.
//

import UIKit
import CoreData
import CoreSpotlight
import MobileCoreServices

let appDelegate = UIApplication.shared.delegate as? AppDelegate

///
/// A view controller that display the list of expenses. It also has the app title and a button to add expenses.
///
class ExpensesViewController: UIViewController {
    @IBOutlet weak var expensesTable: UITableView!
    
    static let ExpenseDetailsIdentifier = "ExpenseDetailsViewController"
    
    /// The list of expenses
    var expenses = [Expense]()

    ///
    ///
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        
        expensesTable.delegate = self
        expensesTable.dataSource = self
        expensesTable.estimatedRowHeight = 100
        expensesTable.rowHeight = UITableViewAutomaticDimension
        expensesTable.allowsMultipleSelectionDuringEditing = false
    }
    
    ///
    ///
    ///
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetch()
        expensesTable.reloadData()
    }

    ///
    /// Callback for when the add button is tapped.
    ///
    @IBAction func didTapAddButton() {
        guard let addExpenseViewController = storyboard?.instantiateViewController(
            withIdentifier: ExpensesViewController.ExpenseDetailsIdentifier) as? ExpenseDetailsViewController
        else { return }
        addExpenseViewController.addDelegate = self
        presentDetail(addExpenseViewController)
    }
    
    ///
    ///
    ///
    func showSearchResult(index: Int) {
        expenses = [expenses[index]]
        expensesTable.reloadData()
    }
}

extension ExpensesViewController: UITableViewDelegate, UITableViewDataSource {
    ///
    ///
    ///
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    ///
    ///
    ///
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenses.count
    }
    
    ///
    ///
    ///
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCell", for: indexPath) as? ExpenseCell else { return UITableViewCell() }
        cell.configureCell(expense: expenses[indexPath.row])
        cell.selectionStyle = .none
        
        // Alternate the background color of cells
        if remainder(Double(indexPath.row + 1), 2) == 0 {
            cell.contentView.backgroundColor = UIColor(red: 0.89, green: 0.88, blue: 0.82, alpha: 1)
        } else {
            cell.contentView.backgroundColor = .white
        }
        
        return cell
    }
    
    ///
    ///
    ///
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    ///
    /// The table has two buttons: Edit and Delete
    ///
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editButton = UITableViewRowAction(
            style: .normal,
            title: "Edit",
            handler: { _, _ in
                guard let editExpenseViewController = self.storyboard?.instantiateViewController(withIdentifier: ExpensesViewController.ExpenseDetailsIdentifier) as? ExpenseDetailsViewController else { return }
                self.presentDetail(editExpenseViewController)
                editExpenseViewController.editDelegate = self
                editExpenseViewController.index = indexPath.row
                editExpenseViewController.expense = self.expenses[indexPath.row]
        })
        
        let deleteButton = UITableViewRowAction(
            style: .destructive,
            title: "Delete",
            handler: { _, _ in
                // Show a confirmation message
                let alertController = UIAlertController(title: "", message: "Are you sure you want to delete this expense?", preferredStyle: .alert)
                
                // Cancel button
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                { (action: UIAlertAction) in
                    alertController.dismiss(animated: true, completion: nil)
                }
                alertController.addAction(cancelAction)
                
                // Delete button
                let deleteAction = UIAlertAction(title: "Delete", style: .destructive)
                { (action: UIAlertAction) in
                    self.removeExpense(at: indexPath)
                    self.fetch()
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    tableView.reloadData()
                }
                alertController.addAction(deleteAction)
                
                self.present(alertController, animated: true, completion: nil)
        })
        
        return [deleteButton, editButton]
    }
}

extension ExpensesViewController {
    ///
    /// Deletes an expense from the database
    ///
    func removeExpense(at indexPath: IndexPath) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        managedContext.delete(expenses[indexPath.row])
        deindex(item: indexPath.row)
        
        do {
            try managedContext.save()
        } catch {
            showAlert(title: "Error", message: "Failed to delete from the database")
        }
    }
    
    ///
    /// Loads the expenses from the database.
    ///
    func fetch() {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        let fetchRequest = NSFetchRequest<Expense>(entityName: "Expense")
    
        do {
            expenses = try managedContext.fetch(fetchRequest)
        } catch {
            showAlert(title: "Error", message: "Failed to load the data from the database")
        }
    }
}

extension ExpensesViewController: AddExpenseDelegate {
    ///
    /// Callback for when an item has been added. It adds the item to the spotlight's index.
    ///
    func didAddExpense() {
        fetch()
        index(item: expenses.count - 1)
    }
}

extension ExpensesViewController: EditExpenseDelegate {
    ///
    /// Callback for when an expense has been edited. It removes the old item from the spotlight's
    /// index and add the new one.
    ///
    func didEditExpense(at itemIndex: Int) {
        deindex(item: itemIndex)
        index(item: itemIndex)
    }
}

extension ExpensesViewController {
    ///
    /// Indexes the item so it can be searchable by spotlight
    ///
    func index(item: Int) {
        let expense = expenses[item]
        
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        attributeSet.title = expense.vehicle?.brand
        attributeSet.contentDescription = expense.location
        
        let item = CSSearchableItem(uniqueIdentifier: "\(item)",
            domainIdentifier: "com.rzsolutionsinc",
            attributeSet: attributeSet)
        CSSearchableIndex.default().indexSearchableItems([item]) { error in
            if let error = error {
                print("Indexing error: \(error.localizedDescription)")
            }
        }
    }
    
    ///
    /// Removes the item from the spotlight's index.
    ///
    func deindex(item: Int) {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: ["\(item)"]) { error in
            if let error = error {
                print("Deindexing error: \(error.localizedDescription)")
            } 
        }
    }
}

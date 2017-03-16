//
//  HomeViewController.swift
//  AccountBook
//
//  Created by yang on 3/6/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController {
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    @IBOutlet weak var lastMonthBalance: UILabel!
    @IBOutlet weak var thisMonthBalance: UILabel!
    @IBOutlet weak var thisMonthExpense: UILabel!
    @IBOutlet weak var thisMonthIncome: UILabel!
    @IBOutlet weak var newTransactionButtonItem: UIBarButtonItem!
    
    private var newTransactionType: String?
    @IBAction func newTransactionButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "New Expense", style: .default) {
            [weak self] (action: UIAlertAction) -> Void in
            self?.newTransactionType = "Expense"
            self?.performSegue(withIdentifier: "Edit New Transaction", sender: self)
        })
        alert.addAction(UIAlertAction(title: "New Income", style: .default) {
            [weak self] (action: UIAlertAction) -> Void in
            self?.newTransactionType = "Income"
            self?.performSegue(withIdentifier: "Edit New Transaction", sender: self)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) {
            (action: UIAlertAction) -> Void in
        })
        alert.modalPresentationStyle = .popover
        alert.popoverPresentationController?.barButtonItem = newTransactionButtonItem
        alert.view.tintColor = UIColor.themeColor()
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Unwind segue actions
    @IBAction func goBack(from segue: UIStoryboardSegue) {
    }
    
    @IBAction func addNewTransaction(from segue: UIStoryboardSegue) {
        if let editor = segue.source as? NewTransactionViewController {
            let type = editor.transactionType!
            let date = editor.datePicker.date as NSDate
            
            // CITE: http://stackoverflow.com/questions/27001914/swift-xcode-string-to-decimal-number
            let decimalFormatter = NumberFormatter()
            decimalFormatter.generatesDecimalNumbers = true
            decimalFormatter.numberStyle = .decimal
            var amount: Decimal? = nil
            if editor.amountTextField.text != nil, editor.amountTextField.text != "" {
                let number = decimalFormatter.number(from: editor.amountTextField.text!)
                amount = number! as? Decimal
            }
            
            let category = editor.pickerView(editor.categoryPicker, titleForRow: editor.categoryPicker.selectedRow(inComponent: 0), forComponent: 0)
            
            // optional fields
            var comment = editor.commentTextField.text
            if comment != nil, comment! == "" {
                comment = nil
            }
            
            var imageData: NSData? = nil
            if editor.image != nil {
                imageData = NSData(data: UIImageJPEGRepresentation(editor.image!, 1.0)!)
            }
            
            if amount != nil, amount! > 0 {
                container?.performBackgroundTask {[weak self] context in
                    _ = Transaction.createNewTransaction(type: type, date: date, amount: amount!, category: category!, comment: comment, imageData: imageData, in: context)
                    try? context.save()
                    DispatchQueue.main.async {
                        self?.updateData()
                    }
                }
            }
        }
    }
    
    // MARK: Core Data
    private func printDatabaseStatistics() {
        if let context = container?.viewContext {
            context.perform {
                let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
                let transactions = try? context.fetch(request)
                for transaction in transactions! {
                    print("\(transaction.type!), \(transaction.date!), \(transaction.amount!), \(transaction.category!), \(transaction.comment ?? "(no comment)")")
                }
            }
        }
    }
    
    private func getStatistics() throws -> (lastBalance: Decimal, currentBalance: Decimal, expense: Decimal, income: Decimal) {
        // self.printDatabaseStatistics()
        
        let startOfThisMonth = Date().startOfMonth()
        let startOfLastMonth = Date().startOfMonth(offset: -1)
        
        let thisMonthPredicate = NSPredicate(format: "date >= %@", startOfThisMonth as NSDate)
        let lastMonthPredicate = NSPredicate(format: "date >= %@ and date < %@", startOfLastMonth as NSDate, startOfThisMonth as NSDate)
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        request.resultType = .dictionaryResultType
        request.propertiesToGroupBy = ["type"]
        let expression = NSExpressionDescription()
        expression.expression = NSExpression(forKeyPath: "@sum.amount")
        expression.expressionResultType = .decimalAttributeType
        expression.name = "totalAmount"
        request.propertiesToFetch = ["type", expression]
        
        var expenseAmount: Decimal = 0
        var incomeAmount: Decimal = 0
        var lastExpenseAmount: Decimal = 0
        var lastIncomeAmount: Decimal = 0
        
        if let context = container?.viewContext {
            do {
                request.predicate = thisMonthPredicate
                var results = try context.fetch(request)
                for result in results {
                    let type = (result as! [String: Any])["type"]! as! String
                    let amount = (result as! [String:Any])[expression.name]! as! Decimal
                    if type == "Expense" {
                        expenseAmount = amount
                    } else {
                        incomeAmount = amount
                    }
                }
                
                request.predicate = lastMonthPredicate
                results = try context.fetch(request)
                for result in results {
                    let type = (result as! [String: Any])["type"]! as! String
                    let amount = (result as! [String:Any])[expression.name]! as! Decimal
                    if type == "Expense" {
                        lastExpenseAmount = amount
                    } else {
                        lastIncomeAmount = amount
                    }
                }
            } catch  {
                throw error
            }
        }
        return (lastIncomeAmount - lastExpenseAmount, incomeAmount - expenseAmount, expenseAmount, incomeAmount)
    }
    
    private func updateData() {
        do {
            let stat = try getStatistics()
            lastMonthBalance.text = getCurrencyString(for: stat.lastBalance)
            thisMonthBalance.text = getCurrencyString(for: stat.currentBalance)
            thisMonthExpense.text = getCurrencyString(for: stat.expense)
            thisMonthIncome.text = getCurrencyString(for: stat.income)
        } catch {
            print("error in HomeViewController.getStatistics()")
        }
    }
    
    // MARK: View Controller Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Cite:http://stackoverflow.com/questions/25388214/how-do-i-change-navigationbar-font-in-swift
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Party LET", size: 30.0)!, NSForegroundColorAttributeName: UIColor.white]
        updateData()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destVC = segue.destination.contents as? NewTransactionViewController {
            destVC.transactionType = self.newTransactionType
        }
    }
}

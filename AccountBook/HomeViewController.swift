//
//  HomeViewController.swift
//  AccountBook
//
//  Created by yang on 3/6/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    @IBOutlet weak var lastMonthBalance: UILabel!
    
    @IBOutlet weak var thisMonthBalance: UILabel!
    
    @IBOutlet weak var thisMonthExpense: UILabel!
    
    @IBOutlet weak var thisMonthIncome: UILabel!
    
    // MARK: - Unwind segue actions
    @IBAction func goBack(from segue: UIStoryboardSegue) {
        // TODO: alert - discard all information
    }
    
    @IBAction func addNewTransaction(from segue: UIStoryboardSegue) {
        if let editor = segue.source as? NewTransactionViewController {
            let type = editor.transactionType!
            let date = editor.datePicker.date as NSDate
            
            // Cite: http://stackoverflow.com/questions/27001914/swift-xcode-string-to-decimal-number
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
            let imageData: NSData? = nil
            
            if amount != nil, amount! > 0 {
                container?.performBackgroundTask {[weak self] context in
                    _ = Transaction.createNewTransaction(type: type, date: date, amount: amount!, category: category!, comment: comment, imageData: imageData, in: context)
                    try? context.save()
                    DispatchQueue.main.async {
                        self?.updateData()
                    }
                }
            } else {
                // TODO: alert - unexpected amount
                print("unexpected amount input")
            }
        }
    }
    
    // MARK: Core Data
    private func printDatabaseStatistics() {
        if let context = container?.viewContext {
            let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
            let transactions = try? context.fetch(request)
            for transaction in transactions! {
                print("\(transaction.type!), \(transaction.date!), \(transaction.amount!), \(transaction.category!), \(transaction.comment ?? "(no comment)")")
            }
        }
    }
    
    private func getStatistics() throws -> (lastBalance: Decimal, currentBalance: Decimal, expense: Decimal, income: Decimal) {
        self.printDatabaseStatistics()
        
        let startOfThisMonth = Date().startOfMonth()
        let startOfLastMonth = Date().startOfMonth(offset: -1)
        
        let expensePredicate = NSPredicate(format: "type = %@", "Expense")
        let incomePredicate = NSPredicate(format: "type = %@", "Income")
        let thisMonthPredicate = NSPredicate(format: "date >= %@", startOfThisMonth as NSDate)
        let lastMonthPredicate = NSPredicate(format: "date >= %@ and date < %@", startOfLastMonth as NSDate, startOfThisMonth as NSDate)
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        request.resultType = .dictionaryResultType
        let expression = NSExpressionDescription()
        expression.expression = NSExpression(forKeyPath: "@sum.amount")
        expression.expressionResultType = .decimalAttributeType
        
        if let context = container?.viewContext {
            do {
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [expensePredicate, thisMonthPredicate])
                expression.name = "thisMonthExpense"
                request.propertiesToFetch = [expression]
                var result = try context.fetch(request)
                let expenseAmount = (result[0] as! [String:Decimal])[expression.name]!
                
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [incomePredicate, thisMonthPredicate])
                expression.name = "thisMonthIncome"
                request.propertiesToFetch = [expression]
                result = try context.fetch(request)
                let incomeAmount = (result[0] as! [String:Decimal])[expression.name]!
                
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [expensePredicate, lastMonthPredicate])
                expression.name = "lastMonthExpense"
                request.propertiesToFetch = [expression]
                result = try context.fetch(request)
                let lastExpenseAmount = (result[0] as! [String:Decimal])[expression.name]!
                
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [incomePredicate, lastMonthPredicate])
                expression.name = "lastMonthIncome"
                request.propertiesToFetch = [expression]
                result = try context.fetch(request)
                let lastIncomeAmount = (result[0] as! [String:Decimal])[expression.name]!
                return (lastIncomeAmount - lastExpenseAmount, incomeAmount - expenseAmount, expenseAmount, incomeAmount)
            } catch  {
                throw error
            }
        }
        return (Decimal(0.0), Decimal(0.0), Decimal(0.0), Decimal(0.0))
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateData()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is TransactionTypeSelectionViewController {
            if let popoverPresentationController = segue.destination.popoverPresentationController {
                popoverPresentationController.delegate = self
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
}

// Cite: - from lecture
extension UIViewController {
    var contents: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? self
        } else {
            return self
        }
    }
}

// Cite: http://stackoverflow.com/questions/33605816/first-and-last-day-of-the-current-month-in-swift
extension Date {
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func startOfMonth(offset: Int) -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: offset), to: self.startOfMonth())!
    }
    
    func endOfMonth(offset: Int) -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: offset+1, day: -1), to: self.startOfMonth())!
    }
    
    func oneWeekBefore() -> Date {
        // 7 days in total including today
        return Calendar.current.date(byAdding: DateComponents(day: -6), to: self.currentDate())!
    }
    
    func currentDate() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: Calendar.current.startOfDay(for: self)))!
    }
}

func getCurrencyString(for num: Decimal) -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .currency
    return numberFormatter.string(for: (num as NSDecimalNumber).doubleValue)!
}

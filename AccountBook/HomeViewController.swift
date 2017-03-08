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
                    self?.printDatabaseStatistics()
                }
            } else {
                // TODO: alert - unexpected amount
                print("unexpected amount input")
            }
        }
    }
    
    private func printDatabaseStatistics() {
        if let context = container?.viewContext {
            context.perform {
                if let transactionCount = try? context.count(for: Transaction.fetchRequest()) {
                    print("\(transactionCount) transactions")
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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

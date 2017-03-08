//
//  NewTransactionViewController.swift
//  AccountBook
//
//  Created by yang on 3/6/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit

class NewTransactionViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var done: UIBarButtonItem!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var amountTextField: UITextField!
    
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    @IBOutlet weak var commentTextField: UITextField!
    
    var transactionType: String? {
        didSet{
            if transactionType != nil {
                self.navigationItem.title = "Add " + transactionType!
            }
        }
    }
    
    override func viewDidLoad() {
        amountTextField.delegate = self
        commentTextField.delegate = self
        datePicker.maximumDate = Date()
    }
    
    // MARK: - PickerView Data Source and Delegate
    private let expenseCategories = ["Necessaries", "Shopping", "Transportation", "Fee", "Others"]
    
    private let incomeCategories = ["Salary", "Finance", "Others"]
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if transactionType == nil {
            return 0
        } else if transactionType! == "Expense" {
            return expenseCategories.count
        } else {
            return incomeCategories.count
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if transactionType == nil {
            return nil
        } else if transactionType! == "Expense" {
            return expenseCategories[row]
        } else {
            return incomeCategories[row]
        }
    }
    
    // MARK: - TextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.restorationIdentifier != nil, textField.restorationIdentifier! == "AmountTextField", textField.text != nil, textField.text! != "" {
            done.isEnabled = true
        }
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

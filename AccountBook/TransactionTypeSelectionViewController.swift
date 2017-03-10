//
//  TransactionTypeSelectionViewController.swift
//  AccountBook
//
//  Created by yang on 3/7/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit

class TransactionTypeSelectionViewController: UITableViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var size = tableView.minimumSize(forSection: 0)
        size.width *= 2.0 // make it a little wider
        preferredContentSize = size
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if let targetViewController = segue.destination.contents as? NewTransactionViewController {
                switch identifier {
                case "Add Expense":
                    targetViewController.transactionType = "Expense"
                default:
                    targetViewController.transactionType = "Income"
                }
            }
        }
    }
}

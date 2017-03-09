//
//  TransactionEntryTableViewCell.swift
//  AccountBook
//
//  Created by yang on 3/8/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit
import CoreData

class TransactionEntryTableViewCell: UITableViewCell {

    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    var transaction: Transaction? {
        didSet {
            updateCellUI()
        }
    }
    
    private func updateCellUI() {
        if let type = transaction?.type {
            let category = transaction!.category!
            categoryLabel.text = "\(type) - \(category)"
            let amountString = getCurrencyString(for: transaction!.amount! as Decimal)
            amountLabel.text = amountString
            if type == "Expense" {
                amountLabel.textColor = UIColor(red: CGFloat(255)/255.0, green: CGFloat(59)/255.0, blue: CGFloat(48)/255.0, alpha: CGFloat(1.0)) // red
            } else {
                amountLabel.textColor = UIColor(red: CGFloat(76)/255.0, green: CGFloat(217)/255.0, blue: CGFloat(100)/255.0, alpha: CGFloat(1.0)) // green
            }
            commentLabel.text = transaction!.comment
        }
    }
}

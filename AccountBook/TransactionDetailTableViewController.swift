//
//  TransactionDetailTableViewController.swift
//  AccountBook
//
//  Created by yang on 3/9/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit
import CoreData

class TransactionDetailTableViewController: UITableViewController {
    var transaction: Transaction? {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if transaction == nil {
            return 0
        }
        var sectionNumber = 1
        if transaction?.comment != nil {
            sectionNumber += 1
        }
        if transaction?.imageData != nil {
            sectionNumber += 1
        }
        return sectionNumber
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Basic Information"
        case 1:
            if transaction?.comment != nil {
                return "Comment"
            }
            fallthrough
        default:
            return "Image"
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if transaction != nil {
            switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "Text Cell", for: indexPath)
                switch indexPath.row {
                case 0:
                    // content = "Type - Category"
                    cell.textLabel?.text = transaction!.type! + " - " + transaction!.category!
                case 1:
                    // content = "Date"
                    cell.textLabel?.text = reformatDateString(for: transaction!.date! as Date)
                default:
                    // content = "Amount"
                    cell.textLabel?.text = getCurrencyString(for: transaction!.amount! as Decimal)
                }
                return cell
            case 1:
                if transaction?.comment != nil {
                    // content = "Comment"
                    let cell = tableView.dequeueReusableCell(withIdentifier: "Text Cell", for: indexPath)
                    cell.textLabel?.text = transaction!.comment
                    return cell
                }
                fallthrough
            default:
                // content = "Image"
                let cell = tableView.dequeueReusableCell(withIdentifier: "Image Cell", for: indexPath)
                return cell
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Text Cell", for: indexPath)
        return cell
    }

}

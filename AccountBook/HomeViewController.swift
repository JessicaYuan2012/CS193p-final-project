//
//  HomeViewController.swift
//  AccountBook
//
//  Created by yang on 3/6/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if let targetViewController = segue.destination.contents as? NewTransactionViewController {
                switch identifier {
                case "Add Expense":
                    targetViewController.transactionType = "Expense"
                    targetViewController.navigationItem.title = "Add New Expense"
                default:
                    targetViewController.transactionType = "Income"
                    targetViewController.navigationItem.title = "Add New Income"
                }
            }
        }
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

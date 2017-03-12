//
//  CompositionViewController.swift
//  AccountBook
//
//  Created by yang on 3/10/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit
import CoreData

// Cite: https://www.raywenderlich.com/131985/core-plot-tutorial-getting-started
class CompositionViewController: UIViewController {
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    @IBOutlet weak var transactionTypeSegmentedControl: UISegmentedControl!
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        showViewControllerForSegment(index)
    }
    
    @IBOutlet weak var contentView: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    private var expenseCategoryAmountTupleListThisMonth: [(String, Decimal)]? = []
    private var incomeCategoryAmountTupleListThisMonth: [(String, Decimal)]? = []
    private var expenseCategoryAmountTupleList: [(String, Decimal)]? = []
    private var incomeCategoryAmountTupleList: [(String, Decimal)]? = []
    
    private func loadData() {
        expenseCategoryAmountTupleListThisMonth?.removeAll()
        incomeCategoryAmountTupleListThisMonth?.removeAll()
        expenseCategoryAmountTupleList?.removeAll()
        incomeCategoryAmountTupleList?.removeAll()
        let startOfThisMonth = Date().startOfMonth()
        let thisMonthPredicate = NSPredicate(format: "date >= %@", startOfThisMonth as NSDate)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        request.resultType = .dictionaryResultType
        request.propertiesToGroupBy = ["type", "category"]
        let expression = NSExpressionDescription()
        expression.expression = NSExpression(forKeyPath: "@sum.amount")
        expression.expressionResultType = .decimalAttributeType
        expression.name = "totalAmount"
        request.propertiesToFetch = ["type", "category", expression]
        
        if let context = container?.viewContext {
            do {
                var results = try context.fetch(request)
                for result in results {
                    let type = (result as! [String: Any])["type"]! as! String
                    let category = (result as! [String: Any])["category"] as! String
                    let amount = (result as! [String:Any])[expression.name]! as! Decimal
                    if type == "Expense" {
                        expenseCategoryAmountTupleList!.append((category, amount))
                    } else {
                        incomeCategoryAmountTupleList!.append((category, amount))
                    }
                }
                
                request.predicate = thisMonthPredicate
                results = try context.fetch(request)
                for result in results {
                    let type = (result as! [String: Any])["type"]! as! String
                    let category = (result as! [String: Any])["category"] as! String
                    let amount = (result as! [String:Any])[expression.name]! as! Decimal
                    if type == "Expense" {
                        expenseCategoryAmountTupleListThisMonth!.append((category, amount))
                    } else {
                        incomeCategoryAmountTupleListThisMonth!.append((category, amount))
                    }
                }
            } catch {
                print("error in CompositionViewController.loadData()")
            }
        }
        
        showViewControllerForSegment(transactionTypeSegmentedControl.selectedSegmentIndex)
    }
    
    private var activeViewController: UIViewController? {
        didSet {
            oldValue?.view.removeFromSuperview()
            
            guard let activeViewController = activeViewController else { return }
            activeViewController.view.frame = contentView.bounds
            contentView.addSubview(activeViewController.view)
            activeViewController.didMove(toParentViewController: self)
        }
    }
    
    private func showViewControllerForSegment(_ index: Int) {
        let viewController = storyboard!.instantiateViewController(withIdentifier: "PieChartPageViewController")
        
        if let viewController = viewController as? PieChartPageViewController {
            if index == 0 {
                viewController.transactionType = "Expense"
                viewController.categoryAmountTupleListThisMonth = expenseCategoryAmountTupleListThisMonth
                viewController.categoryAmountTupleList = expenseCategoryAmountTupleList
            } else {
                viewController.transactionType = "Income"
                viewController.categoryAmountTupleListThisMonth = incomeCategoryAmountTupleListThisMonth
                viewController.categoryAmountTupleList = incomeCategoryAmountTupleList
            }
        }
        
        activeViewController = viewController
    }
    
}

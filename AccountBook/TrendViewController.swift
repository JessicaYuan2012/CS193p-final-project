//
//  TrendViewController.swift
//  AccountBook
//
//  Created by yang on 3/11/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit
import CoreData

class TrendViewController: UIViewController {

    @IBOutlet weak var timeScopeSegmentedControl: UISegmentedControl!

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
    }
    
    @IBOutlet weak var contentView: UIView!
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    private var weekExpenseData: [Decimal] = []
    private var weekIncomeData: [Decimal] = []
    private var monthExpenseData: [Decimal] = []
    private var monthIncomeData: [Decimal] = []
    private var yearExpenseData: [Decimal] = []
    private var yearIncomeData: [Decimal] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    private func loadData() {
        weekExpenseData.removeAll()
        weekIncomeData.removeAll()
        monthExpenseData.removeAll()
        monthIncomeData.removeAll()
        yearExpenseData.removeAll()
        yearIncomeData.removeAll()
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        request.resultType = .dictionaryResultType
        request.propertiesToGroupBy = ["type"]
        let expression = NSExpressionDescription()
        expression.expression = NSExpression(forKeyPath: "@sum.amount")
        expression.expressionResultType = .decimalAttributeType
        expression.name = "totalAmount"
        request.propertiesToFetch = ["type", expression]
        
        func getWeekData(in context: NSManagedObjectContext) throws {
            for daysBefore in -6..<1 {
                let beginDate = Date().daysBefore(offset: daysBefore)
                let endDate = Date().daysBefore(offset: daysBefore+1)
                let predicate = NSPredicate(format: "date >= %@ and date < %@", beginDate as NSDate, endDate as NSDate)
                request.predicate = predicate
                let results = try context.fetch(request)
                for result in results {
                    let type = (result as! [String: Any])["type"]! as! String
                    let amount = (result as! [String:Any])[expression.name]! as! Decimal
                    if type == "Expense" {
                        weekExpenseData.append(amount)
                    } else {
                        weekIncomeData.append(amount)
                    }
                }
                if weekExpenseData.count < daysBefore + 7 {
                    weekExpenseData.append(0)
                }
                if weekIncomeData.count < daysBefore + 7 {
                    weekIncomeData.append(0)
                }
            }
        }
        
        func getMonthData(in context: NSManagedObjectContext) throws {
            var offset = 0
            var beginDate = Date().startOfMonth()
            while beginDate < Date() {
                let endDate = beginDate.daysBefore(offset: 1)
                let predicate = NSPredicate(format: "date >= %@ and date < %@", beginDate as NSDate, endDate as NSDate)
                request.predicate = predicate
                let results = try context.fetch(request)
                for result in results {
                    let type = (result as! [String: Any])["type"]! as! String
                    let amount = (result as! [String:Any])[expression.name]! as! Decimal
                    if type == "Expense" {
                        monthExpenseData.append(amount)
                    } else {
                        monthIncomeData.append(amount)
                    }
                }
                if monthExpenseData.count < offset+1 {
                    monthExpenseData.append(0)
                }
                if monthIncomeData.count < offset+1 {
                    monthIncomeData.append(0)
                }
                offset += 1
                beginDate = endDate
            }
//            let monthDay = monthExpenseData.count
//            for i in 0..<monthDay {
//                print("\(i+1)th day in this month: expense \(monthExpenseData[i]), income \(monthIncomeData[i])")
//            }
        }
        
        func getYearData(in context: NSManagedObjectContext) throws {
            var offset = 0
            var beginDate = Date().startOfYear()
            while beginDate < Date() {
                let endDate = beginDate.monthsBefore(offset: 1)
                let predicate = NSPredicate(format: "date >= %@ and date < %@", beginDate as NSDate, endDate as NSDate)
                request.predicate = predicate
                let results = try context.fetch(request)
                for result in results {
                    let type = (result as! [String: Any])["type"]! as! String
                    let amount = (result as! [String:Any])[expression.name]! as! Decimal
                    if type == "Expense" {
                        yearExpenseData.append(amount)
                    } else {
                        yearIncomeData.append(amount)
                    }
                }
                if yearExpenseData.count < offset+1 {
                    yearExpenseData.append(0)
                }
                if yearIncomeData.count < offset+1 {
                    yearIncomeData.append(0)
                }
                offset += 1
                beginDate = endDate
            }
            let monthNum = yearIncomeData.count
            for i in 0..<monthNum {
                print("\(i+1)th month in this year: expense \(yearExpenseData[i]), income \(yearIncomeData[i])")
            }
        }
        
        if let context = container?.viewContext {
            do {
                try getWeekData(in: context)
                try getMonthData(in: context)
                try getYearData(in: context)
            } catch  {
                print("error in TrendViewController.loadData()")
            }
        }
        
    }
    
}

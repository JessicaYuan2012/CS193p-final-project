//
//  Transaction.swift
//  AccountBook
//
//  Created by yang on 3/7/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit
import CoreData

class Transaction: NSManagedObject {
    class func createNewTransaction(type: String, date: NSDate, amount: Decimal, category: String, comment: String?, imageData: NSData?, in context: NSManagedObjectContext) -> Transaction {
        let transaction = Transaction(context: context)
        transaction.type = type
        transaction.date = date
        transaction.amount = amount as NSDecimalNumber?
        transaction.category = category
        transaction.comment = comment
        transaction.imageData = imageData
        return transaction
    }
}

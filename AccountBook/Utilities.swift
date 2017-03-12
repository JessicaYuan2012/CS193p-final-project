//
//  Utilities.swift
//  AccountBook
//
//  Created by yang on 3/9/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import Foundation
import UIKit

// CITE: - from lecture
extension UIViewController {
    var contents: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? self
        } else {
            return self
        }
    }
}

// CITE: - from lecture
extension UITableView {
    func minimumSize(forSection section: Int) -> CGSize {
        var width: CGFloat = 0
        var height: CGFloat = 0
        for row in 0..<numberOfRows(inSection: section) {
            let indexPath = IndexPath(row: row, section: section)
            if let cell = cellForRow(at: indexPath) ?? dataSource?.tableView(self, cellForRowAt: indexPath) {
                let cellSize = cell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
                width = max(width, cellSize.width)
                height += heightForRow(at: indexPath)
            }
        }
        return CGSize(width: width, height: height)
    }
    
    func heightForRow(at indexPath: IndexPath? = nil) -> CGFloat {
        if indexPath != nil, let height = delegate?.tableView?(self, heightForRowAt: indexPath!) {
            return height
        } else {
            return rowHeight
        }
    }
}

// CITE: http://stackoverflow.com/questions/33605816/first-and-last-day-of-the-current-month-in-swift
extension Date {
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func startOfMonth(offset: Int) -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: offset), to: self.startOfMonth())!
    }
    
    func startOfYear() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year], from: Calendar.current.startOfDay(for: self)))!
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
    
    func daysBefore(offset: Int) -> Date {
        return Calendar.current.date(byAdding: DateComponents(day: offset), to: self.currentDate())!
    }
    
    func monthsBefore(offset: Int) -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: offset), to: self.currentDate())!
    }
}

func getCurrencyString(for num: Decimal) -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .currency
    return numberFormatter.string(for: (num as NSDecimalNumber).doubleValue)!
}

func reformatDateString(_ originalDateString: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZZ"
    let date = dateFormatter.date(from: originalDateString)!
    dateFormatter.dateFormat = "E MMM d, yyyy"
    let formattedDateString = dateFormatter.string(from: date)
    return formattedDateString
}

func reformatDateString(for date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let formattedDateString = dateFormatter.string(from: date)
    return formattedDateString
}

func getMonthDayDateString(for date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM d"
    let formattedDateString = dateFormatter.string(from: date)
    return formattedDateString
}

func getMonthString(for date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM"
    let formattedDateString = dateFormatter.string(from: date)
    return formattedDateString
}

//
//  PieChartPageViewController.swift
//  AccountBook
//
//  Created by yang on 3/10/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit

// Cite: https://spin.atomicobject.com/2015/12/23/swift-uipageviewcontroller-tutorial/
class PieChartPageViewController: UIPageViewController {
    var transactionType: String?
    var categoryAmountTupleListThisMonth: [(String, Decimal)]? = []
    var categoryAmountTupleList: [(String, Decimal)]? = []
    
    fileprivate var orderedViewControllers: [UIViewController] = []
    
    private func setViewControllers() {
        orderedViewControllers.removeAll()
        
        let viewControllerThisMonth = storyboard!.instantiateViewController(withIdentifier: "PieChartViewController")
        
        if let pieChartViewControllerThisMonth = viewControllerThisMonth as? PieChartViewController {
            pieChartViewControllerThisMonth.transactionType = transactionType
            pieChartViewControllerThisMonth.timeScope = "Month"
            pieChartViewControllerThisMonth.categoryAmountTupleList = categoryAmountTupleListThisMonth
            orderedViewControllers.append(pieChartViewControllerThisMonth)
        }
        
        let viewController = storyboard!.instantiateViewController(withIdentifier: "PieChartViewController")
        
        if let pieChartViewController = viewController as? PieChartViewController {
            pieChartViewController.transactionType = transactionType
            pieChartViewController.timeScope = "All"
            pieChartViewController.categoryAmountTupleList = categoryAmountTupleList
            orderedViewControllers.append(pieChartViewController)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViewControllers()
        dataSource = self
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }
}

extension PieChartPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let viewIndex = orderedViewControllers.index(of: viewController) {
            if viewIndex > 0 && viewIndex < orderedViewControllers.count {
                return orderedViewControllers[viewIndex-1]
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let viewIndex = orderedViewControllers.index(of: viewController) {
            if viewIndex >= 0 && viewIndex < orderedViewControllers.count - 1 {
                return orderedViewControllers[viewIndex+1]
            }
        }
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        if let firstViewController = viewControllers?.first {
            if let index = orderedViewControllers.index(of: firstViewController) {
                return index
            }
        }
        return 0
    }
}

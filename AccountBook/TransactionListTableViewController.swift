//
//  TransactionListTableViewController.swift
//  AccountBook
//
//  Created by yang on 3/8/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit
import CoreData


// Cite: search controller https://www.raywenderlich.com/113772/uisearchcontroller-tutorial
class TransactionListTableViewController: FetchedResultsTableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    var fetchedResultsController: NSFetchedResultsController<Transaction>?
    var filteredTransactions = [(String,[Transaction])]()
    let searchController = UISearchController(searchResultsController: nil)
    
    private func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        func matchScope(_ transaction: Transaction) -> Bool {
            if scope == "All" {
                return true
            }
            return scope == transaction.type!
        }
        
        func matchCategoryOrComment(_ transaction: Transaction) -> Bool {
            if searchText == "" {
                return true
            }
            if transaction.category!.lowercased().contains(searchText.lowercased()) {
                return true
            }
            if transaction.comment != nil, transaction.comment!.lowercased().contains(searchText.lowercased()) {
                return true
            }
            return false
        }
        
        filteredTransactions.removeAll()
        if let sections = fetchedResultsController?.sections {
            let sectionNum = sections.count
            for sectionIndex in 0..<sectionNum {
                let name = sections[sectionIndex].name
                let transactionNum = sections[sectionIndex].numberOfObjects
                var transactionList: [Transaction] = []
                for transactionIndex in 0..<transactionNum {
                    if let transaction = sections[sectionIndex].objects?[transactionIndex] as? Transaction {
                        if matchScope(transaction) && matchCategoryOrComment(transaction) {
                            transactionList.append(transaction)
                        }
                    }
                }
                if !transactionList.isEmpty {
                    filteredTransactions.append((name, transactionList))
                }
            }
        }
        
        tableView.reloadData()
    }
    
    private func updateUI() {
        if let context = container?.viewContext {
            let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            fetchedResultsController = NSFetchedResultsController<Transaction>(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: "date",
                cacheName: nil
            )
            try? fetchedResultsController?.performFetch()
            tableView.reloadData()
        }
    }
    
    // MARK: - Table View DataSource
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Transaction Entry", for: indexPath) as! TransactionEntryTableViewCell
        
        if searchController.isActive {
            cell.transaction = filteredTransactions[indexPath.section].1[indexPath.row]
        } else {
            cell.transaction = fetchedResultsController?.object(at: indexPath)
        }
        
        return cell
    }
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
    
    // MARK: - UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.scopeButtonTitles = ["All", "Expense", "Income"]
        searchController.searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
}

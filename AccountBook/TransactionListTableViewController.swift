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
class TransactionListTableViewController: FetchedResultsTableViewController, UISearchResultsUpdating {
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    var fetchedResultsController: NSFetchedResultsController<Transaction>?
    var filteredTransactions = [(String,[Transaction])]()
    let searchController = UISearchController(searchResultsController: nil)
    
    private func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredTransactions.removeAll()
        if let sections = fetchedResultsController?.sections {
            let sectionNum = sections.count
            for sectionIndex in 0..<sectionNum {
                let name = sections[sectionIndex].name
                let transactionNum = sections[sectionIndex].numberOfObjects
                var transactionList: [Transaction] = []
                for transactionIndex in 0..<transactionNum {
                    if let transaction = sections[sectionIndex].objects?[transactionIndex] as? Transaction {
                        if transaction.category!.lowercased().contains(searchText.lowercased()) || (transaction.comment != nil && transaction.comment!.lowercased().contains(searchText.lowercased())) {
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Transaction Entry", for: indexPath) as! TransactionEntryTableViewCell
        if searchController.isActive && searchController.searchBar.text != "" {
            cell.transaction = filteredTransactions[indexPath.section].1[indexPath.row]
        } else {
            cell.transaction = fetchedResultsController?.object(at: indexPath)
        }
        
        return cell
    }
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
}

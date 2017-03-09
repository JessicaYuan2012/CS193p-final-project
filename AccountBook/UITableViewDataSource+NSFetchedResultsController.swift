//
//  UITableViewController extension for use with NSFetchedResultsController
//
//  Created by CS193p Instructor.
//  Copyright © 2017 Stanford University. All rights reserved.
//
//  This implements the UITableViewDataSources
//  assuming a var called fetchedResultsController exists

import UIKit
import CoreData

extension TransactionListTableViewController
{
    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredTransactions.count
        }
        return fetchedResultsController?.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) ->
        Int {
            if searchController.isActive && searchController.searchBar.text != "" {
                return filteredTransactions[section].1.count
            }
            if let sections = fetchedResultsController?.sections, sections.count > 0 {
                return sections[section].numberOfObjects
            } else {
                return 0
            }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.isActive && searchController.searchBar.text != "" {
            return reformatDateString(filteredTransactions[section].0)
        }
        
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return reformatDateString(sections[section].name)
        } else {
            return nil
        }
    }
}

func reformatDateString(_ originalDateString: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZZ"
    let date = dateFormatter.date(from: originalDateString)!
    dateFormatter.dateFormat = "E MMM d, yyyy"
    let formattedDateString = dateFormatter.string(from: date)
    return formattedDateString
}

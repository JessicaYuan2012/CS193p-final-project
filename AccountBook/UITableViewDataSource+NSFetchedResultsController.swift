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
    // MARK: UITableView DataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if searchController.isActive {
            return filteredTransactions.count
        }
        return fetchedResultsController?.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) ->
        Int {
            if searchController.isActive {
                return filteredTransactions[section].1.count
            }
            if let sections = fetchedResultsController?.sections, sections.count > 0 {
                return sections[section].numberOfObjects
            } else {
                return 0
            }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.isActive {
            return reformatDateString(filteredTransactions[section].0)
        }
        
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return reformatDateString(sections[section].name)
        } else {
            return nil
        }
    }
}

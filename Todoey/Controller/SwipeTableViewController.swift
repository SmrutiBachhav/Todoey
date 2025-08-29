//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by Smruti Bachhav on 29/08/25.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //increase teh size of a cell
        tableView.rowHeight = 80.00
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
                        
        cell.delegate = self //sets the cell's delegate 
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    //handles what should happen when user swipes the cell
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        //check if swiped right or left. indexPath tells which row cell was swiped
        guard orientation == .right else { return nil }
        
        //closure for what should happen after being swiped
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            
            self.updateModel(at: indexPath)

        
            print("Deleted")
        }

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")

        return [deleteAction]
    }
    //customize the behavior of the swipe actions
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive //remove
        return options
    }
    
    //update data model when swipe
    func updateModel(at indexPath: IndexPath) {
        print("Deleted message from superClass")
    }
    
}


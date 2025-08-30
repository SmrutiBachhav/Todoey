//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by Smruti Bachhav on 29/08/25.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import UIKit
import SwipeCellKit
import ChameleonFramework

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //increase teh size of a cell
        tableView.rowHeight = 80.00
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
                        
        cell.delegate = self //sets the cell's delegate 
        
        //cell.accessoryType = .disclosureIndicator
        
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
    
    func configurePebbleView(for cell: UITableViewCell, with categoryColor: UIColor) {
        // Check if the pebble view already exists to avoid adding it multiple times
        if let pebbleView = cell.contentView.subviews.first(where: { $0.tag == 99 }) {
            // If it exists, just update its background color
            pebbleView.backgroundColor = categoryColor
            // Update the text color of the label to maintain contrast
            cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
            return
        }

        // Create the pebble-style view
        let pebbleView = UIView()
        pebbleView.tag = 99 // Tag to identify the view later
        pebbleView.translatesAutoresizingMaskIntoConstraints = false
        pebbleView.backgroundColor = categoryColor

        // Apply corner radius for the "pebble" shape
        pebbleView.layer.cornerRadius = 10
        pebbleView.layer.masksToBounds = true // Clip subviews to the rounded corners

        // Add shadow for a 3D effect
        pebbleView.layer.shadowColor = UIColor.black.cgColor
        pebbleView.layer.shadowOffset = CGSize(width: 0, height: 2)
        pebbleView.layer.shadowOpacity = 0.2
        pebbleView.layer.shadowRadius = 4
        pebbleView.layer.masksToBounds = false

        // Add the view to the cell's content view
        cell.contentView.insertSubview(pebbleView, at: 0) // Insert at index 0 so it's behind other content

        // Set up Auto Layout constraints to fill the cell with a margin
        NSLayoutConstraint.activate([
            pebbleView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 5),
            pebbleView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -5),
            pebbleView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 10),
            pebbleView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -10)
        ])

        // Update the text color of the label to maintain contrast
        cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
    }
    
    
}


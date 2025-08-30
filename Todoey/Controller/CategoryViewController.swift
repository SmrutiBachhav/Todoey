//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Smruti Bachhav on 15/08/25.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController  {
    
    //initializing Realm
    let realm = try! Realm()
    
    //category array
    //var categoryArray = [Category]()
    var categories: Results<Category>?
    
    //let defaults = UserDefaults.standard
    
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(".sqlite"))
        
        loadCategories()
        
        //remove separators style
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else { fatalError("Navigation Bar doesn't exist it is null") }
        navBar.backgroundColor = UIColor(hexString: "1B4348")
        //navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]//
    }
    
    //MARK: - TableView DataSource Methods
    
    //to get number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    //specifies how a cell to be shown, to add content to the clicked cell
    //overrides from SwipeTableViewController: Swipe Cell property + cell label text
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //tap into the cell that gets created at current indexPath inside our super view i.e SwipeTableViewController
        let cell  = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories added yet"

        if let category = categories?[indexPath.row] {
            guard let categoryColor = UIColor(hexString: category.color) else {
                fatalError()
            }
            configurePebbleView(for: cell, with: categoryColor)

//            cell.backgroundColor = categoryColor
//            cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
        }
        //cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    
    //MARK: - TableView Delegate Methods
    //To show  todo lists for the selected category
    
    //trigger when we select one of the rows
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)

    }
    
    //for more than view from a view use if (if identifier = "goToItems" then go to this segue)
    //trigger just before we perform the segue(one view to another view)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //reference to destination downcast to ToDoListViewController
        let destinationVC = segue.destination as! TodoListViewController
        
        //grab the todo lists for selected category
        if let indexPath = tableView.indexPathForSelectedRow {
            //save the reference to selected category to selectedCategory
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }

    
    //MARK: - Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        let action = UIAlertAction(title: "Add ", style: .default) { (action) in
            if textField.text == "" {
                let alert = UIAlertController(title: "Error", message: "Please enter a category!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                let newCategory =  Category()
                newCategory.name = textField.text!
                newCategory.color = UIColor.randomFlat().hexValue()
                //self.categoryArray.append(newCategory) no need to append as Results is auto-updating container type
                
                self.save(category: newCategory)
                
                print("Added Category")
        
            }
        }
        
        alert.addTextField { (alertTextField) in
                alertTextField.placeholder = "Create New Category"
                textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Data Manipulation Methods save and load data
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving category: \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadCategories() {
        //fetch data from Realm DB
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    //Delete data using swipe
    override func updateModel(at indexPath: IndexPath) {
        //super.updateModel(at: indexPath)
        if let categoryForDeletion = self.categories?[indexPath.row] { //need to unwrap the optional categories
            do {
                try self.realm.write { //write to update realm db
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error deleting data: \(error)")
            }
        }
    }
}



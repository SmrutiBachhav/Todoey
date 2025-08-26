//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    //var itemArray = ["Find Mike", "Buy milk", "Go to gym"]
    var itemArray = [Item]()
    
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    
    //UserDefaults is an interface to the user's default database where you store key value pairs persistently across launcches of your app
    let defaults = UserDefaults.standard
        
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*for USING USER DEFAULT FOR  LOCAL DATA PERSISTANCE
        let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
         */
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist"))
    
    }
    
    //MARK: - TableView DataSource Method
    
    //to get the number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    //SPECIFIES HOW A CELL IS TO BE SHOWN
    //to add content to the specific cell through we can say indexpath (list of indices that specifies the location)
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //resuable cell - create whole bunch of reusable cells
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        //indexpath.row current row of the current indexpath. row- the value of the current index path of the row
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none
        //        if item.done == true {
        //            cell.accessoryType = .checkmark
        //        } else {
        //            cell.accessoryType = .none
        //        }
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(itemArray[indexPath.row])
        
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        //        if itemArray[indexPath.row].done == false {
        //            itemArray[indexPath.row].done = true
        //        } else {
        //            itemArray[indexPath.row].done = false
        //        }
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
    //MARK: - Add new items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New ToDo", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        //'add' button when done with writing new todo TRIGGERED WHEN USER CLICKS 'ADD' BUTTON AFTER WRITING
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            //what happens when the user clicks the 'Add' button on our UIAlert('add' button is like 'ok' or 'cancel' button in normal alert)
            if textField.text == "" {
                let alert = UIAlertController(title: "Error", message: "Please enter a valid ToDo item", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                //as! AppDelegate downcast to appdelegate
                let newItem = Item(context: self.context)
                newItem.title = textField.text!
                newItem.done = false
                //category
                newItem.parentCategory = self.selectedCategory
                self.itemArray.append(newItem)
                
                self.saveItems()
         
                print("Added!")
            }
        }
        //adding textfield in alert to add the todo item TRIGGERED WHEN USER TYPES IN THE ALERT TEXTFIELD
        alert.addTextField { (alertTextField) in //going to call textfield we create
            alertTextField.placeholder = "Add a new ToDo item"
            textField = alertTextField
        }
        //attaches the action object to alert
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    /* USING USER DEFAULT FOR  LOCAL DATA PERSISTANCE
    //MARK: - Model Manipulation Method
    //encoding data into plist (property list) Items.plist to save it in json format
    func saveItems() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        } catch {
            print("Error encoding the item array! \(error)")
        }
        self.tableView.reloadData()
    }
    //decoding data from plist (property list) Items.plist
    func loadItems() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("Error decoding the item array! \(error)")
            }
        }
    }*/
    
    //MARK: - Model MAnipulation Method save and load data using Core Data
    //encoding converting data to form to data which can be saved into the plist(property list)
    func saveItems() {
        do {
            //attempts to commit changes to store the changes in permanent storage container(prsistentContainer)
            try context.save()
        } catch {
            print("Error savng the context! \(error)")
        }
        //reload the newly added data (reloads the rows and sections of the tableView)
        self.tableView.reloadData()
    }
    
    
    //fetching from the persistent container
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        //search todo list with current parent category matching
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@",selectedCategory!.name!)
        
        //OPTIONAL BINDING
        if let additionalPredicate = predicate { //if predicate is not nil         [category check , search filter matches name]
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray =  try context.fetch(request)
        } catch {
            print("Error fetching data from context! \(error)")
        }
        
        tableView.reloadData()
    }

}

//MARK: - Search Bar methods
extension TodoListViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request : NSFetchRequest<Item> = Item.fetchRequest()
    
        //making search results case and diacritic insensitive cd
        //specifies how we want to query our database
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        //sort the search results
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        //adding sortDescriptor to our request
        //expects an array of NSSortDescriptors thats why it is plural but want single NSSortDescritor for that [sortDescriptor] contains only single item
        
        //fetch results from Persistant container
        loadItems(with: request, predicate: predicate)
       
    }
    
    //triggered when text in the ssearch bar is changed
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //triggred when we write in the search bar and erase it
        if searchBar.text?.count == 0 {
            loadItems()
                    
            //DispatchQueue that manager who assigns projects/ work different threads used when we are changing the UI
            //grabing the  main thread to process in foreground
            DispatchQueue.main.async {
                //telling the search bar to stop being th first responder to be at its og state when app loads cursor and keyboard should be gone
                searchBar.resignFirstResponder()
                
            }
 
        }
    }
}

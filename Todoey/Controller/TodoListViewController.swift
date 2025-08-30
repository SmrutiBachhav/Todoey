//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
     
    @IBOutlet weak var searchBar: UISearchBar!
    //var itemArray = ["Find Mike", "Buy milk", "Go to gym"]
    var todoItems : Results<Item>?
    
    //instance of Realm
    let realm = try! Realm()
    //passed from categoryView....
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist"))
        
        tableView.separatorStyle = .none
/*        navigation Controller here can throw error as todolistViewController is not in nav controller, viewDidLoad is being called controller         property is updated at this pt it is nil, nav stack is not established
        change the background color of the nav bar. using bartintcolor as ot will change the color for both nav bar and status bar unlike bgcolor only for nav bar
        force unwrapping (!) selectedCategory will not be safe here therfore optional binding iflet
        if let colorHex = selectedCategory?.color {
            //check if navcontroller is nil then....
            guard let navBar = navigationController?.navigationBar.barTintColor else {
                fatalError("Nav controller doesn't exist! it is nil")
            }
            navigationController?.navigationBar.barTintColor =  UIColor(hexString: colorHex)
        }
*/
    
    }
    //just before viewDidLoad,nav stack is established, anv controller is not nil
    override func viewWillAppear(_ animated: Bool) {
        if let colorHex = selectedCategory?.color {
            //selectedcategry can forced unwrap as we have done optional binding earlier ?.color
            title = selectedCategory!.name
            //check if navcontroller is nil then....
            guard let navBar = navigationController?.navigationBar else {
                fatalError("Nav controller doesn't exist! it is nil")
            }
            if let navBarColor = UIColor(hexString: colorHex){
                navBar.backgroundColor = navBarColor
                //applies nav items and bar button items
                navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
                
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
                
                searchBar.barTintColor = navBarColor
            
            }

        }
    }
    
    //MARK: - TableView DataSource Method
    
    //to get the number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    //SPECIFIES HOW A CELL IS TO BE SHOWN, get called for every cell/row in tableView
    //to add content to the specific cell through we can say indexpath (list of indices that specifies the location)
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //resuable cell - create whole bunch of reusable cells
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            //indexpath.row current row of the current indexpath. row- the value of the current index path of the row
            cell.textLabel?.text = item.title
            //darken(byper...) is optional and backgroundColor needs definite value therfore if let to unwrap the optional
            //check for UIColor is not empty then darken by.... SelectedCategory will definitely have value as todoItems definitely has value and comes from selectedCategory(loadItems)
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(todoItems!.count)) {
                configurePebbleView(for: cell, with: color)

                //cell.backgroundColor = color
                //text color according to background color (light->black text or dark->white text)
                //cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added Yet!"
        }
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(itemArray[indexPath.row])
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    //realm.delete(item)
                    item.done = !item.done
                }
            } catch {
                print("Error updating Done status: \(error)")
            }
        }
        
        tableView.reloadData()
        
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
                if let currentCategory = self.selectedCategory {
                    do {
                        try self.realm.write {
                            let newItem = Item()
                            newItem.title = textField.text!
                            newItem.dateCreated = Date() //sets current date and time
                            //newItem.done = false already default value assigned in Item class
                            currentCategory.items.append(newItem) //does followin two steps items is forward relation name
        //                    newItem.parentCategory = self.selectedCategory
        //                    self.itemArray.append(newItem)
                        }
                    } catch {
                        print("Error adding new items: \(error)")
                    }

                }
                
                self.tableView.reloadData()
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
    
    //MARK: - Model MAnipulation Method save and load data using Realm
    //saving data is done in the same place where we add data
    
    //fetching from the persistent container
    func loadItems() {
        //items -> forward relationship name we have given in Category class
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
    
    //Delete data using Swipe Cell
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDeletion = self.todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(itemForDeletion)
                }
            } catch {
                print("Error deleting data: \(error)")
            }
        }
    }

}

//MARK: - Search Bar methods
extension TodoListViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //show filtered data according to search. noneed to call load items again as only the filtered data is showned
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true) //shows item created earlier
        tableView.reloadData()

    }
    
    //triggered when text in the ssearch bar is changed
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //triggred when we write in the search bar and erase it
        if searchBar.text?.count == 0 {
            loadItems()
                    
            //DispatchQueue that manager who assigns projects/ work different threads used when we are changing the UI
            //grabbing the  main thread to process in foreground
            DispatchQueue.main.async {
                //telling the search bar to stop being th first responder to be at its og state when app loads cursor and keyboard should be gone
                searchBar.resignFirstResponder()
                
            }
 
        }
    }
}

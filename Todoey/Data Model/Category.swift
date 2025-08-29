//
//  Category.swift
//  Todoey
//
//  Created by Smruti Bachhav on 29/08/25.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

//subclassing with Object to save data in REalm, use Realm
class Category: Object {
    @objc dynamic var name : String = ""
    
    //Creating relationship between the classes or entities or tables
    //FORWARD RELATION for each category items is pointing to list of Item objects
    let items = List<Item>()   //contains list of Item object, initialized as empty list
}

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
    //save hex string in color as realm takes standard datatypes not UIColor...
    @objc dynamic var color : String = ""
    
    //Creating relationship between the classes or entities or tables
    //FORWARD RELATION for each category items is pointing to list of Item objects
    let items = List<Item>()   //contains list of Item object, initialized as empty list
}

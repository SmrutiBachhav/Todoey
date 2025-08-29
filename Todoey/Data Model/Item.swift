//
//  Item.swift
//  Todoey
//
//  Created by Smruti Bachhav on 29/08/25.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var  title : String = ""
    @objc dynamic var done : Bool = false
    @objc dynamic var dateCreated: Date?
    
    //INVERSE RELATIONSHIP
    //var name of inverse relation each item has a parent Category. items is the name of the property of forward releation for inverse relationship
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}

//
//  AppDelegate.swift
//  Destini
//
//  Created by Philipp Muellauer on 01/09/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    //happens as the first thing when the app loads even before the viewDidLoad() method
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as String)
        
        //file location for Realm database where we store data
        print(Realm.Configuration.defaultConfiguration.fileURL?.absoluteString ?? "No Realm file URL")
        
        do {
            _ =  try Realm()
        } catch {
            print("Error initializing Realm: \(error)")
        }
        
        return true
    }
}


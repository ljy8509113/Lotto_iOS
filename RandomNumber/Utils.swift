//
//  Utils.swift
//  RandomNumber
//
//  Created by ljy on 03/05/2019.
//  Copyright © 2019 ljy. All rights reserved.
//

import UIKit
import CoreData

class Utils: NSObject {
    
    class func getContext() -> NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }
}

//
//  DBManager.swift
//  RandomNumber
//
//  Created by ljy on 08/05/2019.
//  Copyright © 2019 ljy. All rights reserved.
//

import UIKit
import CoreData

class DBManager: NSObject {
    static var shared:DBManager = {
        let instance = DBManager()
        return instance
    }()
    
    func fetch(entityName:String, limit:Int = 0) -> [NSManagedObject]? {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
//        let sort = NSSortDescriptor(key: #keyPath(Win.no), ascending: false)
        let sort = NSSortDescriptor(key: "no", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.fetchLimit = limit
        
        return loadData(fetchRequest: fetchRequest)
    }
    
    func loadData(fetchRequest:NSFetchRequest<NSManagedObject>) -> [NSManagedObject]? {
        guard let managedContext = Utils.getContext() else {
            return nil
        }
        do {
            return try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("error : \(error)")
            return nil
        }
    }
    
    func select(entityName:String, pred:NSPredicate) -> [NSManagedObject]? {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        fetchRequest.predicate = pred
        return loadData(fetchRequest: fetchRequest)
    }
    
    func save(){
        do{
            try Utils.getContext()?.save()
        } catch let error as NSError {
            print("error: \(error)")
        }
    }
    
    func makeEntity(entityName:String) -> NSManagedObject? {
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: Utils.getContext()!)
        if let entity = entity {
            return NSManagedObject(entity: entity, insertInto: Utils.getContext())
        }else{
            return nil
        }
    }
    
    func entityCount(entityName:String) -> Int {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        do {
            return try Utils.getContext()?.count(for: fetchRequest) ?? 0
        }catch{
            return 0
        }
    }
}

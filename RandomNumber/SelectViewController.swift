//
//  SelectViewController.swift
//  RandomNumber
//
//  Created by ljy on 02/05/2019.
//  Copyright © 2019 ljy. All rights reserved.
//

import UIKit
import CoreData

class SelectViewController: UIViewController {

    var arrayWin:[NSManagedObject]?
    var arrayNumber:[Int]! = []
    let max:Int = 45
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 1...max {
            arrayNumber.append(i)
        }
        
        // Do any additional setup after loading the view.
        arrayWin = fetch()
        if let arrayWin = self.arrayWin {
            
        }
    }
    
    func fetch() -> [NSManagedObject]? {
        guard let managedContext = Utils.getContext() else {
            return nil
        }
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Win")
        let sort = NSSortDescriptor(key: #keyPath(Win.no), ascending: false)
        
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.fetchLimit = 50
        
        do {
            return try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("error : \(error)")
            return nil
        }
    }

    func getFirst() -> [Int]{
        var dic = Dictionary<Int,Int>()
        
        for i in 1...max {
            dic[i] = 0
        }
        
        for data in self.arrayWin! {
            let win = data as! Win
            dic[Int(win.nm1)] = dic[Int(win.nm1)]! + 1
            dic[Int(win.nm2)] = dic[Int(win.nm2)]! + 1
            dic[Int(win.nm3)] = dic[Int(win.nm3)]! + 1
            dic[Int(win.nm4)] = dic[Int(win.nm4)]! + 1
            dic[Int(win.nm5)] = dic[Int(win.nm5)]! + 1
            dic[Int(win.nm6)] = dic[Int(win.nm6)]! + 1
            dic[Int(win.bonus)] = dic[Int(win.bonus)]! + 1
        }
        
        let array = Array(dic).sorted{ $0.value > $1.value}
        
        var result:[Int]! = []
        for i in 0...10 {
            let data = array[i]
            result.append(data.value)
        }
        return result
    }
    
}

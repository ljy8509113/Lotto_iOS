//
//  Win+CoreDataProperties.swift
//  
//
//  Created by ljy on 03/05/2019.
//
//

import Foundation
import CoreData


extension Win {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Win> {
        return NSFetchRequest<Win>(entityName: "Win")
    }

    @NSManaged public var bonus: Int16
    @NSManaged public var date: NSDate?
    @NSManaged public var nm1: Int16
    @NSManaged public var nm2: Int16
    @NSManaged public var nm3: Int16
    @NSManaged public var nm4: Int16
    @NSManaged public var nm5: Int16
    @NSManaged public var nm6: Int16
    @NSManaged public var no: Int32

}

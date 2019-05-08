//
//  Saved+CoreDataProperties.swift
//  
//
//  Created by ljy on 08/05/2019.
//
//

import Foundation
import CoreData


extension Saved {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Saved> {
        return NSFetchRequest<Saved>(entityName: "Saved")
    }

    @NSManaged public var no: Int32
    @NSManaged public var nm1: Int16
    @NSManaged public var result: String?
    @NSManaged public var nm6: Int16
    @NSManaged public var nm5: Int16
    @NSManaged public var nm4: Int16
    @NSManaged public var nm3: Int16
    @NSManaged public var nm2: Int16

}

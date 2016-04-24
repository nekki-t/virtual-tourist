//
//  Report.swift
//  VirtualTourist
//
//  Created by nekki t on 2016/04/24.
//  Copyright © 2016年 next3. All rights reserved.
//

import UIKit
import CoreData

class Report: NSManagedObject {
    
    // MARK: - Key Strings
    struct Keys {
        static let Date = "date"
        static let Detail = "detail"
    }
    
    // MARK: - Attributes
    @NSManaged var date: NSDate
    @NSManaged var detail: String
    
    // MARK: - Initializers
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(addDetail: String, context: NSManagedObjectContext) {
        // Core Data
        let entity = NSEntityDescription.entityForName("Report", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Dictionary
        date = NSDate()
        detail = addDetail
    }
}

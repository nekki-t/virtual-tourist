//
//  Pin.swift
//  VirtualTourist
//
//  Created by nekki t on 2016/02/13.
//  Copyright © 2016年 next3. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class Pin: NSManagedObject {
    
    // MARK: - Key Strings
    struct Keys {
        static let LastPage = "lastPage"
        static let Longitude = "longitude"
        static let Latitude = "latitude"
        static let TotalPages = "totalPages"
    }

    // MARK: - Attributes
    @NSManaged var lastPage: Int
    @NSManaged var longitude: Double
    @NSManaged var latitude: Double
    @NSManaged var totalPages: Int
    @NSManaged var photos: [Photo]
    
    // MARK: - Initializers
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Dictionary
        lastPage = (dictionary[Keys.LastPage] as! NSNumber).integerValue
        longitude = dictionary[Keys.Longitude] as! Double
        latitude = dictionary[Keys.Latitude] as! Double
        totalPages = (dictionary[Keys.TotalPages] as! NSNumber).integerValue
    }   
}

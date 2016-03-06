//
//  Photo.swift
//  VirtualTourist
//
//  Created by nekki t on 2016/02/29.
//  Copyright © 2016年 next3. All rights reserved.
//

import UIKit
import CoreData

class Photo: NSManagedObject {
    struct Keys {
        static let Id = "id"
        static let PhotoPath = "photo_path"
        static let Title = "title"
    }
    
    @NSManaged var id: NSNumber
    @NSManaged var photoPath: String?
    @NSManaged var title: String?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        // Core Data
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Dictionary
        id = dictionary[Keys.Id] as! Int
        title = dictionary[Keys.Title] as? String
        photoPath = dictionary[Keys.PhotoPath] as? String
        
    }
    
    var photo: UIImage? {
        get {
            return FlickrClient.Caches.imageCache.imageWithIdentifier(photoPath)
        }
        
        set {
           FlickrClient.Caches.imageCache.storeImage(photo, withIdentifier: photoPath!)
        }
    }
    
}

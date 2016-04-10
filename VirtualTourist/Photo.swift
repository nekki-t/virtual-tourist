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
        static let IdString = "idString"
        static let PhotoPath = "photo_path"
        static let Title = "title"
    }
    
    @NSManaged var uniquePhotoId: String
    @NSManaged var idString: String
    @NSManaged var photoPath: String?
    @NSManaged var title: String?
    @NSManaged var pin: Pin
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        // Core Data
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Dictionary
        idString = dictionary[Keys.IdString] as! String
        title = dictionary[Keys.Title] as? String
        photoPath = dictionary[Keys.PhotoPath] as? String
        
        
    }
    
    var image: UIImage? {
        get {
            return FlickrClient.Caches.imageCache.imageWithIdentifier(idString)
        }
        
        set {
           FlickrClient.Caches.imageCache.storeImage(newValue, withIdentifier: idString)
        }
    }
}

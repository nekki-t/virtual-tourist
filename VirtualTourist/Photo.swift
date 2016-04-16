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
        static let PhotoPath = "photoPath"
        static let Title = "title"
        static let DateUpload = "dateUpload"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    }
    
    @NSManaged var uniquePhotoId: String
    @NSManaged var idString: String
    @NSManaged var photoPath: String
    @NSManaged var title: String
    @NSManaged var dateUpload: String
    @NSManaged var latitude: String
    @NSManaged var longitude: String
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
        title = dictionary[Keys.Title] as! String
        photoPath = dictionary[Keys.PhotoPath] as! String
        dateUpload = dictionary[Keys.DateUpload] as! String
        latitude = dictionary[Keys.Latitude] as! String
        longitude = dictionary[Keys.Longitude] as! String
        uniquePhotoId = NSUUID().UUIDString
    }
    
    
    var image: UIImage? {
        get {
            return FlickrClient.Caches.imageCache.imageWithIdentifier(uniquePhotoId)
        }
        
        set {
            FlickrClient.Caches.imageCache.storeImage(newValue, withIdentifier: uniquePhotoId)
            NSNotificationCenter.defaultCenter().postNotificationName(getObserverName(), object: nil)
        }
    }
    
    func getObserverName() -> String {
        let result = SharedConstants.LoadPhotosObserver + uniquePhotoId
        return result
    }
}

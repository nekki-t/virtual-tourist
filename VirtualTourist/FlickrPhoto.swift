//
//  FlickrPhoto.swift
//  VirtualTourist
//
//  Created by nekki t on 2016/03/03.
//  Copyright © 2016年 next3. All rights reserved.
//

import Foundation
struct FlickrPhoto {
    
    var photo: String?
    var id: String?
    var title: String?
    var urlQ: String?
    var latitude: String?
    var longitude: String?
    var dateUpload: String?
    
    
    init(){}
    
    init(dictionary: [String: AnyObject]){
        if let inPhoto = dictionary[DictionaryKeys.Photo] as? String {
            photo = inPhoto
        }
        
        if let inId = dictionary[DictionaryKeys.Id] as? String {
            id = inId
        }
        
        if let inTitle = dictionary[DictionaryKeys.Title] as? String {
            title = inTitle
        }
        
        if let inUrlQ = dictionary[DictionaryKeys.UrlQ] as? String {
            urlQ = inUrlQ
        }
        
        if let inLatitude = dictionary[DictionaryKeys.Latitude] as? String {
            latitude = inLatitude
        }
        
        if let inLongitude = dictionary[DictionaryKeys.Longitude] as? String {
            longitude = inLongitude
        }
        
        if let inDateUpload = dictionary[DictionaryKeys.DateUpload] as? String {
            dateUpload = inDateUpload
        }
    }
    
    func getPhotoDictionary() -> [String: AnyObject]{
        return [
            Photo.Keys.IdString: id!,
            Photo.Keys.Title: title!,
            Photo.Keys.PhotoPath: urlQ!,
            Photo.Keys.DateUpload: dateUpload!,
            Photo.Keys.Latitude: latitude!,
            Photo.Keys.Longitude: longitude!
        ]
    }
    
    struct DictionaryKeys {
        static let Photo = "photo"
        static let Id = "id"
        static let Title = "title"
        static let UrlQ = "url_q"
        static let DateUpload = "dateupload"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    }
}
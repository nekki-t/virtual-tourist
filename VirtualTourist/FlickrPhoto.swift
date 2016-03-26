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
    var urlM: String?
    var heightM: Int?
    var widthM: Int?
    
    
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
        
        if let inUrlM = dictionary[DictionaryKeys.UrlM] as? String {
            urlM = inUrlM
        }
        
        if let inHeightM = dictionary[DictionaryKeys.HeightM] as? Int {
            heightM = inHeightM
        }
        
        if let inWidthM = dictionary[DictionaryKeys.WidthM] as? Int {
            widthM = inWidthM
        }
    }
    
    func getPhotoDictionary() -> [String: AnyObject]{
        return [
            Photo.Keys.IdString: id!,
            Photo.Keys.Title: title!,
            Photo.Keys.PhotoPath: urlM!
        ]
    }
    
    struct DictionaryKeys {
        static let Photo = "photo"
        static let Id = "id"
        static let Title = "title"
        static let UrlM = "url_m"
        static let HeightM = "height_m"
        static let WidthM = "width_m"        
    }
}
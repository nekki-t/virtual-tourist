//
//  FlickrResponse.swift
//  VirtualTourist
//
//  Created by nekki t on 2016/03/03.
//  Copyright © 2016年 next3. All rights reserved.
//

import Foundation
struct FlickrResponse {
    
    var total = 0
    var page = 0
    var pages = 0
    var perPage = 0
    var photos = [FlickrPhoto]()
    
    init(){}
    
    init(dictionary: NSDictionary){
        if let inTotal = dictionary[DictionaryKeys.Total] as? String {
            total = Int(inTotal)!
        }
        
        if let inPage = dictionary[DictionaryKeys.Page] as? Int {
            page = inPage
        }
        
        if let inPages = dictionary[DictionaryKeys.Pages] as? Int {
            pages = inPages
        }
        
        if let inPerPage = dictionary[DictionaryKeys.PerPage] as? Int {
            perPage = inPerPage
        }
        
        if let inPhotos = dictionary[DictionaryKeys.Photo] as? [[String: AnyObject]] {
            for photo in inPhotos {
                //print(photo)
                let newPhoto = FlickrPhoto(dictionary: photo)
                photos.append(newPhoto)
            }
        }
    }
    
    struct DictionaryKeys {
        
        static let Total = "total"
        static let Photo = "photo"
        static let Page = "page"
        static let Pages = "pages"
        static let PerPage = "perpage"
    }
}

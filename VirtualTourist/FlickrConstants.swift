//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by nekki t on 2016/02/14.
//  Copyright © 2016年 next3. All rights reserved.
//

import Foundation

extension FlickrClient {
    struct Constants {
        static let BASE_URL = "https://api.flickr.com/services/rest/"
        static let METHOD_NAME = "flickr.photos.search"
        static let API_KEY = "183b53e2d1b4c9faedc9373b9e3be7d3" //このキーは自分のものと書き換えてください。
        static let EXTRAS = "url_m"
        static let SAFE_SEARCH = "1"
        static let DATA_FORMAT = "json"
        static let NO_JSON_CALLBACK = "1"
        static let ACCURACY = "6"
        
        static let BOUNDING_BOX_HALF_WIDTH = 1.0
        static let BOUNDING_BOX_HALF_HEIGHT = 1.0
        static let LAT_MIN = -90.0
        static let LAT_MAX = 90.0
        static let LON_MIN = -180.0
        static let LON_MAX = 180.0
        
        static let PER_PAGE = 21
        static let DEFAULT_PAGE = 1
    }
    
    struct JsonKeys {
        static let METHOD = "method"
        static let API_KEY = "api_key"
        static let BBOX = "bbox"
        static let SAFE_SEARCH = "safe_search"
        static let EXTRAS = "extras"
        static let FORMAT = "format"
        static let NO_JSON_CALL_BACK = "nojsoncallback"
        static let ACCURACY = "accuracy"
        static let PER_PAGE = "per_page"
        static let PAGE = "page"
        
    }
    // MARK: - JSON Response Keys
    struct JSONResponseKeys {
        
        static let PAGE = "page"
        static let PAGES = "pages"
        static let PER_PAGE = "perpage"
        static let PHOTO = "photo"
        
        static let IMAGE_URL = "url_m"
        static let IMAGE_HEIGHT = "height_m"
        static let IMAGE_WIDTH = "width_m"
        static let TITLE = "title"
    }
}

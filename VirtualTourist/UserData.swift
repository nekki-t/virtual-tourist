//
//  UserData.swift
//  VirtualTourist
//
//  Created by nekki t on 2016/02/13.
//  Copyright © 2016年 next3. All rights reserved.
//

import Foundation
import MapKit

class UserData {
    
    // MARK: - Variables
    var hasLastLocation = false
    var path: String  = ""
    
    private var _lastRegion = MKCoordinateRegion()
    var lastRegion: MKCoordinateRegion {
        return _lastRegion
    }
    
    
    // MARK: - Keys: CONSTANTS
    struct Keys{
        static let HasLastLocation = "hasLastLocation"
        static let LatitudeDelta = "latitudeDelta"
        static let LongitudeDelta = "longitudeDelta"
        static let CenterLatitude  = "centerLatitude"
        static let CenterLongitude = "centerLongitude"
    }
    
    // MARK: - Singleton
    class func sharedInstance() -> UserData {
        struct Static {
            static let instance = UserData()
        }
        return Static.instance
    }
    
    // MARK: - init
    private init() {
        path = NSSearchPathForDirectoriesInDomains(.DocumentationDirectory, .UserDomainMask, true)[0]
        load()
    }
    
    // MARK: - Read from persistent data
    private func load() {
        let ud = NSUserDefaults.standardUserDefaults()
        if let hd = ud.objectForKey(Keys.HasLastLocation) as? Bool {
            hasLastLocation = hd
        }
        if let latDel = ud.objectForKey(Keys.LatitudeDelta) as? Double {
            _lastRegion.span.latitudeDelta = latDel
        }
        if let lonDel = ud.objectForKey(Keys.LongitudeDelta) as? Double {
            _lastRegion.span.longitudeDelta = lonDel
        }
        if let lat = ud.objectForKey(Keys.CenterLatitude) as? Double {
            _lastRegion.center.latitude = lat
        }
        if let lon = ud.objectForKey(Keys.CenterLongitude) as? Double {
            _lastRegion.center.longitude = lon
        }
    }
    
    // MARK: - Save and Clear last location info
    func saveLastRegion(region: MKCoordinateRegion){
       let ud = NSUserDefaults.standardUserDefaults()
        
        _lastRegion = region
        print(region)
        
        ud.setObject(true, forKey: Keys.HasLastLocation)
        ud.setObject(_lastRegion.span.latitudeDelta, forKey: Keys.LatitudeDelta)
        ud.setObject(_lastRegion.span.longitudeDelta, forKey: Keys.LongitudeDelta)
        ud.setObject(_lastRegion.center.latitude, forKey: Keys.CenterLatitude)
        ud.setObject(_lastRegion.center.longitude, forKey: Keys.CenterLongitude)
    }
    
    func clearLastLocation() {
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setObject(false, forKey: Keys.HasLastLocation)
        ud.setObject(nil, forKey: Keys.LatitudeDelta)
        ud.setObject(nil, forKey: Keys.LongitudeDelta)
        ud.setObject(nil, forKey: Keys.CenterLatitude)
        ud.setObject(nil, forKey: Keys.CenterLongitude)
        
        _lastRegion = MKCoordinateRegion()
    }
}
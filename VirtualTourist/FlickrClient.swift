//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by nekki t on 2016/02/14.
//  Copyright © 2016年 next3. All rights reserved.
//

import Foundation
class FlickrClient: NSObject {
    var session: NSURLSession
    var flickrResponse: FlickrResponse?
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: - Class Func
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
    
    // MARK: - Shared Image Cache
    struct Caches {
        static let imageCache = ImageCache()
    }
    
    
    
    func getPhotosInfoByLocation(longitude: Double, latitude: Double, currentPage: Int!, maxUploadDate: String?, completionHandler: (success: Bool, error: String?) -> Void){
        
        var methodArguments = [
            FlickrClient.JsonKeys.METHOD: FlickrClient.Constants.METHOD_NAME,
            FlickrClient.JsonKeys.API_KEY: FlickrClient.Constants.API_KEY,
            FlickrClient.JsonKeys.BBOX: createBoundingBoxString(latitude, longitude: longitude),
            FlickrClient.JsonKeys.SAFE_SEARCH: FlickrClient.Constants.SAFE_SEARCH,
            FlickrClient.JsonKeys.EXTRAS: FlickrClient.Constants.EXTRAS,
            FlickrClient.JsonKeys.FORMAT: FlickrClient.Constants.DATA_FORMAT,
            FlickrClient.JsonKeys.NO_JSON_CALL_BACK: FlickrClient.Constants.NO_JSON_CALLBACK,
            FlickrClient.JsonKeys.ACCURACY: FlickrClient.Constants.ACCURACY,
            FlickrClient.JsonKeys.PER_PAGE: String(FlickrClient.Constants.PER_PAGE),
            FlickrClient.JsonKeys.PAGE: String(currentPage)
        ]
        if let pMaxUploadDate: String  = maxUploadDate {
            methodArguments[FlickrClient.JsonKeys.MAX_UPLOAD_DATE] = decreaseTimeStampString(pMaxUploadDate)
        }

        let urlString = FlickrClient.Constants.BASE_URL + FlickrClient.escapedParameters(methodArguments);
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            print(error)
            guard error == nil else {
                completionHandler(success: false, error: "Search Method failed (Request Failed)!")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    completionHandler(success: false, error: "Invalid Response! Status Code: \(response.statusCode)")
                } else if let response = response {
                    completionHandler(success: false, error: "Invalid Response! Response: \(response)")
                } else {
                    completionHandler(success: false, error: "Invalid Resonse")
                }
                return
            }
            
            guard let data = data else {
                completionHandler(success: false, error: "No data was returned!")
                return
            }
            
            FlickrClient.parseJSONWithCompletionHandler(data){
                JSONResult, error in
                //print(JSONResult)
            
                guard let photosDictionary = JSONResult["photos"] as? NSDictionary else {
                    completionHandler(success: false, error: "No key 'Photos' in \(JSONResult)")
                    return
                }
                
                self.flickrResponse = FlickrResponse(dictionary: photosDictionary)
                completionHandler(success: true, error: nil)
            
                //print(photosDictionary)
            }
            
        }

        task.resume()
    }

    
    // MARK: - Helpers
    // Decrease 1 from TimeStamp StringValue
    func decreaseTimeStampString(target: String) -> String {
        var timeStamp = Int(target)!
        timeStamp = timeStamp - 1
        return String(timeStamp)
    }
    
    /* LAT/LON Manipulation */
    func createBoundingBoxString(latitude: Double, longitude: Double) -> String{
        // Bottom Left
        let bottom_left_lon = max(longitude - FlickrClient.Constants.BOUNDING_BOX_ADJUST_WIDTH, FlickrClient.Constants.LON_MIN)
        let bottom_left_lat = max(latitude  - FlickrClient.Constants.BOUNDING_BOX_ADJUST_WIDTH, FlickrClient.Constants.LAT_MIN)

        // Top Right
        let top_right_lon = min(longitude + FlickrClient.Constants.BOUNDING_BOX_ADJUST_HEIGHT, FlickrClient.Constants.LON_MAX)
        let top_right_lat = min(latitude + FlickrClient.Constants.BOUNDING_BOX_ADJUST_HEIGHT, FlickrClient.Constants.LAT_MAX)
        
        let bbox = "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
        print("BBOX: \(bbox)")
        
        return bbox
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHnadler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do{
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey: "Could not parse the data as JSON: '\(data)'"]
            completionHnadler(result: nil, error:  NSError(domain: "parseJSONWithCompetionHandler", code: 1, userInfo: userInfo))
        }
        completionHnadler(result: parsedResult, error: nil)
    }
    
    /* Helper: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String: AnyObject]) -> String {
        var urlVars = [String]()
        for(key, value) in parameters {
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }

}

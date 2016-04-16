//
//  SharedFunctions.swift
//  VirtualTourist
//
//  Created by nekki t on 2016/03/06.
//  Copyright © 2016年 next3. All rights reserved.
//

import UIKit
import CoreData
class SharedFunctions {
    
    // MARK: Common Alert
    class func showAlert(title: String?, message: String?, targetViewController: UIViewController) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .Alert)
        let actionOK = UIAlertAction(title: "Dissmiss", style: .Default, handler: nil)
        alert.addAction(actionOK)
        targetViewController.presentViewController(alert, animated: true, completion: nil)
    }
    
    class func loadPhotos(fetchedObjects: NSArray?) {
        for item in fetchedObjects! {
            let photo = item as! Photo;
            let url = NSURL(string: photo.photoPath)!
            self.getDataFromUrl(url) { (data, response, err)  in
                dispatch_async(dispatch_get_main_queue()) {
                    print("Download Started")
                    print("lastPathComponent: " + (url.lastPathComponent ?? ""))
                    guard let data = data where err == nil else { return }
                    photo.image = UIImage(data: data)
                    CoreDataStackManager.sharedInstance().saveContext()
                }
            }
        }        
    }
    
    private class func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) {
            (data, response, error) in
            completion(data: data, response: response, error: error)
        }.resume()
    }
}

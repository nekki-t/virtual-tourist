//
//  SharedFunctions.swift
//  VirtualTourist
//
//  Created by nekki t on 2016/03/06.
//  Copyright © 2016年 next3. All rights reserved.
//

import UIKit
class SharedFunctions {
    
    // MARK: Common Alert
    class func showAlert(title: String?, message: String?, targetViewController: UIViewController) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .Alert)
        let actionOK = UIAlertAction(title: "Dissmiss", style: .Default, handler: nil)
        alert.addAction(actionOK)
        targetViewController.presentViewController(alert, animated: true, completion: nil)
    }

}

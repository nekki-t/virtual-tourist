//
//  PhotoCell.swift
//  VirtualTourist
//
//  Created by nekki t on 2016/02/13.
//  Copyright © 2016年 next3. All rights reserved.
//

import UIKit



class PhotoCell: UICollectionViewCell {
    
    // MARK: - Variables
    var loadIndicator: UIActivityIndicatorView?
    var photoLoadedObserver: NSObjectProtocol?
    var photo: Photo?{
        didSet{
            showIndicator()
            dispatch_async(dispatch_get_main_queue()) {
                if let p = self.photo {
                    
                    if let image = p.image {
                        self.photoImage.image = image
                        self.backgroundColor = UIColor.whiteColor()
                        self.hideIndicator()
                    }
                }
            }
        }
    }
    
    
    // MARK: - IBOutlet
    @IBOutlet weak var photoImage: UIImageView!
    
    
    // MARK: - Functions
    // MARK: observer
    func registerPhotoLoadedObserver(observerName: String) {
        removePhotoLoadedObserver()
        photoLoadedObserver = NSNotificationCenter.defaultCenter().addObserverForName(
            observerName,
            object: nil,
            queue: nil,
            usingBlock: {
                notification in
                self.photoImage.image = self.photo!.image
                self.backgroundColor = UIColor.whiteColor()
                self.hideIndicator()
                self.removePhotoLoadedObserver()
            }
        )
    }
    
    func removePhotoLoadedObserver() {
        if photoLoadedObserver != nil {
            NSNotificationCenter.defaultCenter().removeObserver(self.photoLoadedObserver!)
        }
    }
    
    
  
    
    // MARK: Indicator
    func showIndicator() {
        self.loadIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, self.bounds.width, self.bounds.height))
        self.loadIndicator?.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        if let loading = self.loadIndicator {
            loading.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
            loading.color = UIColor.blackColor()
            self.userInteractionEnabled = false
            self.addSubview(loading)
            loading.startAnimating()
        }
    }
    
    func hideIndicator() {
        if let loading = self.loadIndicator {
            loading.removeFromSuperview()
            self.userInteractionEnabled = true
            self.loadIndicator = nil
        }
    }
}

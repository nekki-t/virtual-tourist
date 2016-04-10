//
//  PhotoCell.swift
//  VirtualTourist
//
//  Created by nekki t on 2016/02/13.
//  Copyright © 2016年 next3. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImage: UIImageView!
    
    var photo: Photo? {
        didSet{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                if let p = self.photo {
                    if let image = p.image {
                        self.photoImage.image = image
                        self.backgroundColor = UIColor.whiteColor()
                    }
                }
            }
        }
    }
}

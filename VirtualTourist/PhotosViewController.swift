//
//  PhotosViewController.swift
//  VirtualTourist
//
//  Created by nekki t on 2016/02/13.
//  Copyright © 2016年 next3. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class PhotosViewController: UIViewController, UICollectionViewDataSource, MKMapViewDelegate, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {
    
    //###################################################################################
    // MARK: - Constants
    

    //###################################################################################
    // MARK: - IB Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomButton: UIBarButtonItem!
    @IBOutlet weak var map: MKMapView!
    
    //###################################################################################
    // MARK: - Variables
    var region: MKCoordinateRegion!
    var pin: Pin!
    
    // MARK: SharedContext
    var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext!
    
    var loadPhotosObserver: NSObjectProtocol?
    
    //###################################################################################
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        dropPinOnMap()
        
        var error: NSError?
        do{
            try fetchedResultsController.performFetch()
        } catch let err as NSError {
            error = err
        }
        
        if let error = error {
            print("Error performing initial fetch: \(error)")
        }
        
    }
    
    
    
    // Layout the collection view
    override func viewDidLayoutSubviews() {
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let width = floor(self.collectionView.frame.size.width / 3)
        layout.itemSize = CGSize(width: width, height: width)
        collectionView.collectionViewLayout = layout
    }
    
    //###################################################################################
    // MARK: - Observer Function
    func registerLoadPhotosObserver() {
//        loadPhotosObserver = NSNotificationCenter.defaultCenter().addObserverForName(
//            SharedConstants.LoadPhotosObserver,
//            object: <#T##AnyObject?#>, queue: <#T##NSOperationQueue?#>, usingBlock: <#T##(NSNotification) -> Void#>)
    }
    
    
    // MARK: - MapView Delegates
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.animatesDrop = true
        
        return pinView
    }
    
    func dropPinOnMap() {
        let point = MKPointAnnotation()
        point.coordinate = CLLocationCoordinate2D()
        point.coordinate.latitude = pin.latitude
        point.coordinate.longitude = pin.longitude
        map.addAnnotation(point)
        map.showAnnotations([point], animated: true)
    }
    
    //###################################################################################
    // MARK: - NSFetchedResultsController
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = []
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    //###################################################################################
    // MARK: - UICollectionView
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        
        print("number Of Cells: \(sectionInfo.numberOfObjects)")
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell
        self.configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCell
//        
//        if let index = selectedIndexes.indexOf(indexPath) {
//            selectedIndexes.removeAtIndex(index)
//        } else {
//            selectedIndexes.append(indexPath)
//        }
//        
//        configureCell(cell, atIndexPath: indexPath)
//        
       // updateBottomButton()
    }

    //###################################################################################
    // MARK: - Local Functions
    func configureUI() {
        map.delegate = self
    }
    
    // MARK: - Configure Cell
    func configureCell(cell: PhotoCell, atIndexPath indexPath: NSIndexPath) {
        let photo = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        cell.photo = photo
        
//        if let _ = selectedIndexes.indexOf(indexPath) {
//            cell.colorPanel.alpha = 0.05
//        } else {
//            cell.colorPanel.alpha = 1.0
//        }
    }

}

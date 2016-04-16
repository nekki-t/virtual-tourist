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
    let defaultButtonTitle = "New Collection"
    let deletingButtonTitle = "Remove Selected Pictures"

    //###################################################################################
    // MARK: - IB Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomButton: UIBarButtonItem!
    @IBOutlet weak var map: MKMapView!
    
    //###################################################################################
    // MARK: - Variables
    var region: MKCoordinateRegion!
    var pin: Pin!
    var isLoding = false
    
    var selectedIndexes = [NSIndexPath]()
    
    // Keep the changes. We will keep track of insertions, deletions, and updates.
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    
    // MARK: SharedContext
    var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext!
    
    //###################################################################################
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomButton.title = defaultButtonTitle
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
        
        print(pin.objectID)
        
        collectionView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        
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
    
    // MARK: Button Actions
    @IBAction func getNewCollection(sender: UIBarButtonItem) {
        isLoding = true
        bottomButton.enabled = false
    }
    
    //###################################################################################
    // MARK: - NSFetchedResultsController
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "pin==%@", self.pin)
        
        print(fetchRequest.predicate)
        
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
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell
        self.configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCell
        
        if let index = selectedIndexes.indexOf(indexPath) {
            selectedIndexes.removeAtIndex(index)
            if selectedIndexes.count < 1 {
                bottomButton.title = defaultButtonTitle
            }
        } else {
            selectedIndexes.append(indexPath)
            bottomButton.title = deletingButtonTitle
        }
        
        configureCell(cell, atIndexPath: indexPath)
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type{
            
        case .Insert:
            print("Insert an item")
            // Here we are noting that a new Color instance has been added to Core Data. We remember its index path
            // so that we can add a cell in "controllerDidChangeContent". Note that the "newIndexPath" parameter has
            // the index path that we want in this case
            insertedIndexPaths.append(newIndexPath!)
            break
        case .Delete:
            print("Delete an item")
            // Here we are noting that a Color instance has been deleted from Core Data. We keep remember its index path
            // so that we can remove the corresponding cell in "controllerDidChangeContent". The "indexPath" parameter has
            // value that we want in this case.
            deletedIndexPaths.append(indexPath!)
            break
        case .Update:
            print("Update an item.")
            // We don't expect Color instances to change after they are created. But Core Data would
            // notify us of changes if any occured. This can be useful if you want to respond to changes
            // that come about after data is downloaded. For example, when an images is downloaded from
            // Flickr in the Virtual Tourist app
            updatedIndexPaths.append(indexPath!)
            break
        case .Move:
            print("Move an item. We don't expect to see this in this app.")
            break
        default:
            break
        }
    }


    //###################################################################################
    // MARK: - Local Functions
    func configureUI() {
        map.delegate = self
    }
    
    // MARK: - Configure Cell
    func configureCell(cell: PhotoCell, atIndexPath indexPath: NSIndexPath) {
        if cell.photo == nil {
            let photo = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
            cell.photo = photo
            cell.registerPhotoLoadedObserver(photo.getObserverName())
        }
        
        if let _ = selectedIndexes.indexOf(indexPath) {
            cell.photoImage.alpha = 0.3
        } else {
            cell.photoImage.alpha = 1.0
        }
    }

}

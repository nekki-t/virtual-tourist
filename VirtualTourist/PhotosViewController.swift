//
//  PhotosViewController.swift
//  VirtualTourist
//
//  Created by nekki t on 2016/02/13.
//  Copyright © 2016年 next3. All rights reserved.
//

import UIKit
import CoreData
import Foundation
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
    
    var selectedIndexes = [NSIndexPath]()
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    
    // MARK: SharedContext
    var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext!
    
    // MARK: NSFetchedResultsController
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        let sortDescriptor = NSSortDescriptor(key: "dateUpload", ascending: false)
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "pin==%@", self.pin)
        
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    //###################################################################################
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
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
            print("Error performing initial fetch for Photos: \(error)")
        } else {
            collectionView.reloadData()
        }
        
    }
    
    // Layout the collection view
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let width = floor(self.collectionView.frame.size.width / 3)
        layout.itemSize = CGSize(width: width, height: width)
        collectionView.collectionViewLayout = layout
    }
    
    //###################################################################################
    // MARK: - MapView Delegates
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.animatesDrop = true
        
        // set call out
        pinView?.canShowCallout = true
        
        
        // Information Button
        let rightButton: AnyObject! = UIButton(type: UIButtonType.DetailDisclosure)
        pinView?.rightCalloutAccessoryView = rightButton as? UIView
        
        return pinView

    }
    // pin tapped
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let controller = storyboard!.instantiateViewControllerWithIdentifier("ReportsViewController") as! ReportsViewController
        controller.pin = pin
        navigationController!.pushViewController(controller, animated: true)
    }

    
    func dropPinOnMap() {
        let point = MKPointAnnotation()
        point.coordinate = CLLocationCoordinate2D()
        point.coordinate.latitude = pin.latitude
        point.coordinate.longitude = pin.longitude
        point.title = "You can add memo!"
        point.subtitle = "tap the right icon"
        map.addAnnotation(point)
        map.showAnnotations([point], animated: true)
        map.selectedAnnotations = [point]
    }
    
    
    //###################################################################################
    // MARK: - Button Actions
    @IBAction func bottomButtonTapped(sender: UIBarButtonItem) {
        
        if selectedIndexes.isEmpty {
            setNewCollectionButton(true)
            deleteAllPhotos()
            loadNewCollection()
        } else {
            deleteSelectedPhotos()
            bottomButton.title = defaultButtonTitle
        }
    }
    
    //###################################################################################
    // MARK: - Deleting Methods
    func deleteSelectedPhotos() {
        var photosToDelete = [Photo]()
        
        for indexPath in selectedIndexes {
            photosToDelete.append(fetchedResultsController.objectAtIndexPath(indexPath) as! Photo)
        }
        
        for photo in photosToDelete {
            sharedContext.deleteObject(photo)
        }
        CoreDataStackManager.sharedInstance().saveContext()
        collectionView.reloadData()
        selectedIndexes = [NSIndexPath]()
    }
    func deleteAllPhotos() {
        for photo in fetchedResultsController.fetchedObjects as! [Photo] {
            sharedContext.deleteObject(photo)
        }
        CoreDataStackManager.sharedInstance().saveContext()
        collectionView.reloadData()
    }
    
    //###################################################################################
    // MARK: - Load New Collection
    func loadNewCollection() {
        
        let addCount = FlickrClient.Constants.PER_PAGE - fetchedResultsController.fetchedObjects!.count
        //let randomPage = Int(arc4random_uniform(UInt32(pin.totalPages))) + 1
        
        let nextPage = getNextPage()
        
        // Get Photos from API
        FlickrClient.sharedInstance().getPhotosInfoByLocation(pin.longitude, latitude: pin.latitude, currentPage: nextPage){
            success, error in
            
            if success {
                var index = 0
                for photoInfo in FlickrClient.sharedInstance().flickrResponse!.photos {
                    let photo = Photo(dictionary: photoInfo.getPhotoDictionary(), context: self.sharedContext)
                    photo.pin = self.pin
                    index += 1
                    if (index == addCount) {
                        break
                    }
                }
                self.pin.lastPage = nextPage
                CoreDataStackManager.sharedInstance().saveContext()
                print(">> NEXT PAGE ################################")
                print(nextPage)
                
                let fetchRequest = NSFetchRequest(entityName: "Photo")
                fetchRequest.predicate = NSPredicate(format: "pin==%@", self.pin)
                
                var results: NSArray?
                do {
                    results = try CoreDataStackManager.sharedInstance().managedObjectContext?.executeFetchRequest(fetchRequest)
                } catch let error as NSError {
                    print("Could not fetch \(error), \(error.userInfo)")
                }
                
                dispatch_async(dispatch_get_main_queue()){
                    self.setNewCollectionButton(false)
                }
                Photo.loadPhotos(results)
            } else {
                print(error)
            }
        }
    }
    
    // return next page to get photos from API
    func getNextPage() -> Int {
        var nextPage = pin.lastPage + 1
        if nextPage > pin.totalPages {
            nextPage = SharedConstants.StartPage
        }
        return nextPage
    }
    


    //###################################################################################
    // MARK: - NSFetchedResultsController Delegate
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        // We are about to handle some new changes. Start out with empty arrays for each change type
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
        
        print("in controllerWillChangeContent")
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type{
            
        case .Insert:
            //print("Insert an item")
            insertedIndexPaths.append(newIndexPath!)
            break
        case .Delete:
            //print("Delete an item")
            deletedIndexPaths.append(indexPath!)
            break
        case .Update:
            //print("Update an item.")
            updatedIndexPaths.append(indexPath!)
            break
        case .Move:
            //print("Move an item. We don't expect to see this in this app.")
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        print("in controllerDidChangeContent. changes.count: \(insertedIndexPaths.count + deletedIndexPaths.count)")
        
        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItemsAtIndexPaths([indexPath])
            }
            
        }, completion: nil)
    }
    
    
    
    //###################################################################################
    // MARK: - UICollectionView
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //return self.fetchedResultsController.sections?.count ?? 0
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        print(sectionInfo.numberOfObjects)
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
    
  


    //###################################################################################
    // MARK: - Configure UI/cell
    func configureUI() {
        map.delegate = self
    }
    
    func configureCell(cell: PhotoCell, atIndexPath indexPath: NSIndexPath) {
        let photo = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        cell.photo = photo
        cell.registerPhotoLoadedObserver(photo.getObserverName())
        
        
        if let _ = selectedIndexes.indexOf(indexPath) {
            cell.photoImage.alpha = 0.3
        } else {
            cell.photoImage.alpha = 1.0
        }
    }
    
    //###################################################################################
    // MARK: - Helpers
    func setNewCollectionButton(isLoading: Bool) {
        bottomButton.title = defaultButtonTitle
        if isLoading {
            bottomButton.enabled = false
        } else {
            bottomButton.enabled = true
        }
    }

    

}

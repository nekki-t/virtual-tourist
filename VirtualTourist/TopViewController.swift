//
//  TopViewController.swift
//  VirtualTourist
//
//  Created by nekki t on 2016/02/12.
//  Copyright © 2016年 next3. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class TopViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate, CLLocationManagerDelegate {
    //###################################################################################
    // MARK: - variables
    var toDelete = false
    var bottomEditMessageCurrentPosY:CGFloat = 0.0
    var mapTap = UITapGestureRecognizer()
    var longTap = UILongPressGestureRecognizer()
    var manager: CLLocationManager!
    var annotations = [MKPointAnnotation]()
    var pins:[Pin]!
    
    
    //###################################################################################
    // MARK: SharedContext
    var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext!
    
    //###################################################################################
    // MARK: - IBOutlets
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var bottomEditMessageHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomEditMessagePosY: NSLayoutConstraint!
    @IBOutlet weak var mapPosY: NSLayoutConstraint!
    
    //###################################################################################
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start the fetched results controller
        var error: NSError?
        do{
            try fetchedResultsController.performFetch()
        } catch let err as NSError {
            error = err
        }
        
        if let error = error {
            print("Error performing initial fetch: \(error)")
        }
        
        configureUI()
        loadLocations()
        loadStartupLocation()
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationItem.title = "Virtual Tourist"
    }
    
    //###################################################################################
    // MARK: - IBActions
    @IBAction func editButtonTapped(sender: AnyObject) {
        if editButton.title == "Edit" {
            editButton.title = "Done"
            toDelete = true
            UIView.animateWithDuration(0.5, animations: {() -> Void in
                self.mapPosY.constant -= self.bottomEditMessageHeight.constant
                self.bottomEditMessagePosY.constant += self.bottomEditMessageHeight.constant
                self.view.layoutIfNeeded()
            })
            
        } else {
            editButton.title = "Edit"
            toDelete = false
            UIView.animateWithDuration(0.5, animations: {() -> Void in
                self.mapPosY.constant += self.bottomEditMessageHeight.constant
                self.bottomEditMessagePosY.constant -= self.bottomEditMessageHeight.constant
                self.view.layoutIfNeeded()
            })
        }
    }
    
    //###################################################################################
    // MARK: - MapViewDelegate
    // putting pins on the map
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let pinView = MKPinAnnotationView()
        pinView.animatesDrop = true
        pinView.annotation = annotation
        pinView.pinTintColor = UIColor.redColor()
        pinView.sizeToFit()
        pinView.draggable = true
        
        return pinView
    }
    
    // Save Region
    func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool) {
        UserData.sharedInstance().saveLastRegion(map.region)
    }
    
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        switch(newState){
        case .Starting:
            print("drag started") // Just to know the event started
        case .Ending:
            guard let index = annotations.indexOf(view.annotation as! MKPointAnnotation) where index > -1 else {
                // nothing to do ... for safety coding
                return
            }
            updatePinData(index, location: view.annotation!.coordinate)
            
            print("drag ended")
        default:
            break
        }
    }
   
    //###################################################################################
    // MARK: - Custom Actions
    
    // Map
    func mapLongPressed (sender: UILongPressGestureRecognizer) {
        if(sender.state != .Began) {
            return
        }
        
        let location = sender.locationInView(map)
        let point:CLLocationCoordinate2D = map.convertPoint(location, toCoordinateFromView: map)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = point
        let newPin = insertNewPin(annotation,  span: map.region.span)
        
        // Get Photos from API
        FlickrClient.sharedInstance().getPhotosInfoByLocation(point.longitude, latitude: point.latitude, currentPage: SharedConstants.StartPage){
            success, error in
            
            if success {
                for photoInfo in FlickrClient.sharedInstance().flickrResponse!.photos {
                    let photo = Photo(dictionary: photoInfo.getPhotoDictionary(), context: self.sharedContext)
                    photo.pin = newPin
                }
                newPin.totalPages = FlickrClient.sharedInstance().flickrResponse!.pages
                newPin.lastPage = SharedConstants.StartPage
                CoreDataStackManager.sharedInstance().saveContext()
                dispatch_async(dispatch_get_main_queue()){
                    self.map.addAnnotation(annotation)
                }
                let fetchRequest = NSFetchRequest(entityName: "Photo")
                fetchRequest.predicate = NSPredicate(format: "pin==%@", newPin)
                
                var results: NSArray?
                do {
                    results = try CoreDataStackManager.sharedInstance().managedObjectContext?.executeFetchRequest(fetchRequest)
                } catch let error as NSError {
                    print("Could not fetch \(error), \(error.userInfo)")
                }
                Photo.loadPhotos(results)
            } else {
                print(error)
            }
        }
    }
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    //###################################################################################
    // MARK: - Local Functions
    func configureUI () {
        
        // setting up map
        map.delegate = self
        
        longTap.addTarget(self, action: #selector(mapLongPressed))
        map.addGestureRecognizer(longTap)
        
        // tap gesture
        mapTap = UITapGestureRecognizer(target: self, action: #selector(mapTapped))
        map.addGestureRecognizer(mapTap)
        
        bottomEditMessagePosY.constant -= bottomEditMessageHeight.constant
    }
    
    func mapTapped(gesture: UITapGestureRecognizer) {
        let tapPoint: CGPoint = gesture.locationInView(map)
        if let annotationView = map.hitTest(tapPoint, withEvent: nil) as? MKPinAnnotationView {
            if let index = annotations.indexOf(annotationView.annotation as! MKPointAnnotation) {
                if toDelete {
                    if index > -1 {
                        deletePinData(index)
                    }
                    map.removeAnnotation(annotationView.annotation!)
                } else {
                    let controller = storyboard!.instantiateViewControllerWithIdentifier("PhotoAlbumViewController") as! PhotoAlbumViewController
                    controller.region = map.region
                    controller.pin = pins[index]
                    navigationItem.title = "OK"
                    navigationController!.pushViewController(controller, animated: true)

                }
            }
        }
    }
    
    
    // set map from saved region
    func loadStartupLocation() {
        let userData = UserData.sharedInstance()
        if userData.hasLastLocation{
            map.setRegion(userData.lastRegion, animated:true)
        }
    }
    
    // put all pins
    func loadLocations() {
        pins = fetchedResultsController.fetchedObjects as! [Pin]
        
        for pin in  pins {
            let cllc = CLLocationCoordinate2D(latitude: Double(pin.latitude), longitude: pin.longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = cllc
            annotation.title = String(pin.objectID)
            annotations.append(annotation)
            map.addAnnotation(annotation)
        }
    }
    
    //###################################################################################
    // MARK: - Core Data
    func insertNewPin(annotation: MKPointAnnotation, span: MKCoordinateSpan) -> Pin{
        
        let dictionary: [String: AnyObject] = [
            Pin.Keys.LastPage: 0,
            Pin.Keys.Latitude : annotation.coordinate.latitude,
            Pin.Keys.Longitude : annotation.coordinate.longitude,
            Pin.Keys.TotalPages: 0
        ]
        
        let pin = Pin(dictionary: dictionary, context: sharedContext)
        
        CoreDataStackManager.sharedInstance().saveContext()
        pins.append(pin)
        annotations.append(annotation)
        return pin
    }
    
    func updatePinData(index: Int, location: CLLocationCoordinate2D) {
        let pin = pins[index]
        pin.latitude = location.latitude
        pin.longitude = location.longitude
        
        // delete all photos which belong to the old pin
        let photosFetchRequest = NSFetchRequest(entityName: "Photo")
        photosFetchRequest.predicate = NSPredicate(format: "pin==%@", pin)
        
        do {
            let result = try CoreDataStackManager.sharedInstance().managedObjectContext!.executeFetchRequest(photosFetchRequest)
            for photo in result as! [Photo] {
                sharedContext.deleteObject(photo)
            }
        } catch let err as NSError{
            print(err)
        }
        
        CoreDataStackManager.sharedInstance().saveContext()
        
        FlickrClient.sharedInstance().getPhotosInfoByLocation(location.longitude, latitude: location.latitude, currentPage: SharedConstants.StartPage){
            success, error in
            
            if success {
                for photoInfo in FlickrClient.sharedInstance().flickrResponse!.photos {
                    let photo = Photo(dictionary: photoInfo.getPhotoDictionary(), context: self.sharedContext)
                    photo.pin = pin
                }
                pin.totalPages = FlickrClient.sharedInstance().flickrResponse!.pages
                pin.lastPage = SharedConstants.StartPage
                CoreDataStackManager.sharedInstance().saveContext()
                
                let fetchRequest = NSFetchRequest(entityName: "Photo")
                fetchRequest.predicate = NSPredicate(format: "pin==%@", pin)
                
                var results: NSArray?
                do {
                    results = try CoreDataStackManager.sharedInstance().managedObjectContext?.executeFetchRequest(fetchRequest)
                } catch let error as NSError {
                    print("Could not fetch \(error), \(error.userInfo)")
                }
                Photo.loadPhotos(results)
            } else {
                print(error)
            }
        }
    }
    
    
    func deletePinData(index: Int) {
        sharedContext.deleteObject(pins[index])
        pins.removeAtIndex(index)
        annotations.removeAtIndex(index)
        CoreDataStackManager.sharedInstance().saveContext()
        
        if pins.count < 1 {
            UserData.sharedInstance().clearLastLocation()
        }
    }
    
    //###################################################################################
    // MARK: - NSFetchedResultsController
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        fetchRequest.sortDescriptors = []
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    // MARK: - Fetched Results Controller Delegate
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        print("in controllerWillChangeContent")
    }
}

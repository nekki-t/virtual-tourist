//
//  ReportsViewController.swift
//  VirtualTourist
//
//  Created by nekki t on 2016/04/24.
//  Copyright © 2016年 next3. All rights reserved.
//

import UIKit
import CoreData

class ReportsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    // MARK: - Variables
    var pin: Pin!
    
    // MARK: - IB Outlits
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: SharedContext
    var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext!
    
    // MARK: NSFetchedResultsController
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Report")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
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
        title = "Tourist's Reports"
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(self.addReport))
        let editButton = editButtonItem()
        navigationItem.rightBarButtonItems = [addButton, editButton]
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        var error: NSError?
        
        do {
            try fetchedResultsController.performFetch()
        } catch let err as NSError {
            error = err
        }
        
        if let error = error {
            print("Error performing initial fetch for Reports: \(error)")
        } else {
            tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.endEditing(true)
    }
    //###################################################################################
    // MARK: - Actions
    func addReport() {
        tableView.endEditing(true)
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
        controller.pin = pin
        presentViewController(controller, animated: true, completion: nil)
        
    }
    //###################################################################################
    // MARK: - Table View Delegate and Data Source
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellReusedId = "reportCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReusedId, forIndexPath: indexPath)
        let report = fetchedResultsController.objectAtIndexPath(indexPath) as! Report
        cell.detailTextLabel!.text = String(report.date)
        cell.textLabel!.text = report.details
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        
        return sectionInfo.numberOfObjects
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let report = fetchedResultsController.objectAtIndexPath(indexPath) as! Report
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
        controller.pin = pin
        controller.report = report
        presentViewController(controller, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            let report = fetchedResultsController.objectAtIndexPath(indexPath) as! Report
            sharedContext.deleteObject(report)
            CoreDataStackManager.sharedInstance().saveContext()
            do {
                try fetchedResultsController.performFetch()
            } catch let err as NSError {
                print(err)
            }

            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
        default:
            break
        }
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.editing = editing
    }
}

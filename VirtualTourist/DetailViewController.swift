//
//  DetailViewController.swift
//  VirtualTourist
//
//  Created by nekki t on 2016/04/25.
//  Copyright © 2016年 next3. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITextViewDelegate {
    //###################################################################################
    // MARK: - Constants
    let textViewGuideString = "Please enter your tour report here"
    //###################################################################################
    // MARK: - Variables
    var pin: Pin!
    var report: Report?
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    // MARK: SharedContext
    var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext!
    
    //###################################################################################
    // MARK: - IBOutlets
    @IBOutlet weak var reportTextView: UITextView!
    @IBOutlet weak var cancelButton: BorderedButton!
    
    //###################################################################################
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        reportTextView.text = report?.details
        configureUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        
        addKeyboardDismissRecognizer()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        removeKeyboardDissmissRecognizer()
    }
    
    //###################################################################################
    // MARK: - IBActions
    @IBAction func saveBtnTapped(sender: AnyObject) {
        if reportTextView.text == "" || reportTextView.text == textViewGuideString {
            SharedFunctions.showAlert("No Report!", message: "Please input something to save!", targetViewController: self)
            return
        }
        
        if let rep = report {
            // update
            rep.date = NSDate()
            rep.details = reportTextView.text
        } else {
            // new
            report = Report(addDetails: reportTextView.text, context: sharedContext)
            report!.pin = pin
        }
      
        CoreDataStackManager.sharedInstance().saveContext()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelBtnTapped(sender: AnyObject) {
        view.endEditing(true)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //###################################################################################
    // MARK: - View Funcitons
    func configureUI() {
        reportTextView.delegate = self
        updateReportTextView()
        cancelButton.backgroundColor = UIColor.redColor()
        cancelButton.backingColor = UIColor.redColor()
        cancelButton.highlightedBackingColor = UIColor.redColor()
        
        // Tap Recognizer
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap))
        tapRecognizer?.numberOfTapsRequired = 1
    }
    
    func updateReportTextView () {
        if(reportTextView.text == "" || reportTextView.text == textViewGuideString) {
            reportTextView.text = textViewGuideString
            reportTextView.textColor = UIColor.lightGrayColor()
            reportTextView.textAlignment = .Center
        } else {
            reportTextView.textAlignment = .Left
            reportTextView.textColor = UIColor.blackColor()
        }
    }
    
    //###################################################################################
    // MARK: - textView Delegate
    // clear if text is the guide text
    func textViewDidBeginEditing(textView: UITextView) {
        reportTextView.textAlignment = .Left
        reportTextView.textColor = UIColor.blackColor()
        if(reportTextView.text == textViewGuideString) {
            reportTextView.text = ""
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            updateReportTextView()
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        updateReportTextView()
    }
    
    //###################################################################################
    // MARK: Keyboard(Show/Hide)
    func addKeyboardDismissRecognizer(){
        view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDissmissRecognizer(){
        view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {        
        view.endEditing(true)
    }
}

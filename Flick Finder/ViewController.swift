//
//  ViewController.swift
//  Flick Finder
//
//  Created by Vineet Joshi on 1/27/18.
//  Copyright © 2018 Vineet Joshi. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    let ALERT_MSG = "Please enter a search phrase or coordinates for both latitude and longitude."
    
    @IBOutlet weak var flickImageView: UIImageView!
    @IBOutlet weak var phraseTextField: UITextField!
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        phraseTextField.delegate = self
        // infoLabel.text = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // NSNotifications provide a way to announce information throughout an app, even across classes
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.unsubscribeFromKeyboardNotifications()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func searchForImage(_ sender: Any) {
        phraseTextField.resignFirstResponder()
        latitudeTextField.resignFirstResponder()
        longitudeTextField.resignFirstResponder()
        
        if (phraseTextField.text == "") && (latitudeTextField.text == "" || longitudeTextField.text == "") {
            let alert = UIAlertController(title: "Invalid Search", message: ALERT_MSG, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                NSLog("The \"Invalid Search Entries\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        // do more ...
    }
    
}


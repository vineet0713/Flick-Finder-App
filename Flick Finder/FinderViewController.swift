//
//  FinderViewController.swift
//  Flick Finder
//
//  Created by Vineet Joshi on 1/27/18.
//  Copyright © 2018 Vineet Joshi. All rights reserved.
//

import UIKit

class FinderViewController: UIViewController, UITextFieldDelegate {
    
    let SEARCH_MSG = "Please enter a search phrase or coordinates for both latitude and longitude."
    let COORDINATES_MSG = "Please enter a valid latitude [-90, 90] and a valid longitude [-180, 180]."
    let PHOTO_MSG = "There were no photos found for your request."
    
    @IBOutlet weak var flickImageView: UIImageView!
    @IBOutlet weak var phraseTextField: UITextField!
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    
    var currentImageIndex: Int = -1
    
    // MARK: Overriden functions from UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        phraseTextField.delegate = self
        latitudeTextField.delegate = self
        longitudeTextField.delegate = self
        infoLabel.text = ""
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
    
    // MARK: UITextFieldDelegate function
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func searchForImage(_ sender: Any) {
        phraseTextField.resignFirstResponder()
        latitudeTextField.resignFirstResponder()
        longitudeTextField.resignFirstResponder()
        
        if (phraseTextField.text!.isEmpty) && (latitudeTextField.text!.isEmpty || longitudeTextField.text!.isEmpty) {
            displayAlert(title: "Invalid Search", message: SEARCH_MSG)
            return
        }
        
        var methodParameters: [String:String] = [:]
        var userValues = [phraseTextField.text!]
        
        var latitude: Double = 0.0
        var longitude: Double = 0.0
        
        if latitudeTextField.text!.isEmpty == false && longitudeTextField.text!.isEmpty == false {
            if let userLatitude = Double(latitudeTextField.text!), let userLongitude = Double(longitudeTextField.text!) {
                latitude = userLatitude
                longitude = userLongitude
                if coordinatesAreValid(latitude: userLatitude, longitude: userLongitude) {
                    userValues.append(getBBoxString(latitude: latitude, longitude: longitude))
                } else {
                    displayAlert(title: "Invalid Coordinates", message: COORDINATES_MSG)
                    if phraseTextField.text!.isEmpty {
                        return
                    }
                }
            } else {
                displayAlert(title: "Invalid Coordinates", message: COORDINATES_MSG)
                if phraseTextField.text!.isEmpty {
                    return
                }
            }
        } else {
            userValues.append("")
        }
        
        infoLabel.text = "Searching..."
        
        let parameterKeys = Constants.FlickrParameterKeys.orderedValues
        let parameterValues = Constants.FlickrParameterValues.orderedValues
        var userValueCounter = 0
        
        for i in 0..<parameterKeys.count {
            if parameterValues[i] == "USER_VALUE" {
                if userValues[userValueCounter] == "" {
                    userValueCounter += 1
                    continue
                }
                methodParameters[parameterKeys[i]] = userValues[userValueCounter]
                userValueCounter += 1
            } else {
                methodParameters[parameterKeys[i]] = parameterValues[i]
            }
        }
        
        displayImageFromFlickr(methodParameters, with: nil)
    }
    
    func getBBoxString(latitude: Double, longitude: Double) -> String {
        var bboxArray: [String] = []
        bboxArray.append("\(max(longitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLonRange.0))")
        bboxArray.append("\(max(latitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLatRange.0))")
        bboxArray.append("\(min(longitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLonRange.1))")
        bboxArray.append("\(min(latitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLatRange.1))")
        
        return bboxArray.joined(separator: ",")
    }
    
    // MARK: Helper for displaying UIAlertController
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
            NSLog("The \"\(title)\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: Helper for checking valid latitude/longitude
    
    func coordinatesAreValid(latitude: Double, longitude: Double) -> Bool {
        let latLower = Constants.Flickr.SearchLatRange.0
        let latUpper = Constants.Flickr.SearchLatRange.1
        let longLower = Constants.Flickr.SearchLonRange.0
        let longUpper = Constants.Flickr.SearchLonRange.1
        
        return (latLower...latUpper ~= latitude) && (longLower...longUpper ~= longitude)
    }
    
    // MARK: Flickr API
    
    func displayImageFromFlickr(_ methodParameters: [String:Any], with pageNumber: Int?) {
        if pageNumber != nil {
            var methodParametersWithPage = methodParameters
            methodParametersWithPage[Constants.FlickrParameterKeys.Page] = pageNumber
        }
        
        // make a request to Flickr
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(methodParameters))
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (statusCode >= 200 && statusCode <= 299) else {
                print("Your request returned a status code other than 2xx.")
                return
            }
            
            guard let data = data else {
                print("No data was returned.")
                return
            }
            
            var parsedResult: [String:Any]!
            
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
            } catch {
                print("Could not parse the data as JSON.")
                return
            }
            
            // check if Flickr returned an error
            guard let flickrStatus = parsedResult[Constants.FlickrResponseKeys.Status] as? String, flickrStatus == Constants.FlickrResponseValues.OKStatus else {
                print("Flickr API returned an error.")
                return
            }
            
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:Any] else {
                print("Could not find key \(Constants.FlickrResponseKeys.Photos).")
                return
            }
            
            if pageNumber == nil {
                guard let pages = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int else {
                    print("Could not find key \(Constants.FlickrResponseKeys.Pages).")
                    return
                }
                
                // because Twitter's API only allows us to choose from the first 40 pages:
                let truncatedPages = min(pages, 40)
                let randomPage = Int(arc4random_uniform(UInt32(truncatedPages)))
                self.displayImageFromFlickr(methodParameters, with: randomPage)
            } else {
                guard let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:Any]] else {
                    print("Could not find key \(Constants.FlickrResponseKeys.Photo).")
                    return
                }
                
                if photoArray.count == 0 {
                    performUIUpdatesOnMain {
                        self.flickImageView.image = nil
                        self.infoLabel.text = ""
                    }
                    self.displayAlert(title: "No Photos Found", message: self.PHOTO_MSG)
                    return
                }
                
                // makes sure that the newly displayed image will be different than current one:
                var randomPhotoIndex = self.currentImageIndex
                while randomPhotoIndex == self.currentImageIndex {
                    randomPhotoIndex = Int(arc4random_uniform(UInt32(photoArray.count)))
                }
                self.currentImageIndex = randomPhotoIndex
                
                let photoDictionary = photoArray[randomPhotoIndex]
                
                guard let imageURLString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
                    print("Could not find key \(Constants.FlickrResponseKeys.MediumURL).")
                    return
                }
                
                guard let imageTitleString = photoDictionary[Constants.FlickrResponseKeys.Title] as? String else {
                    print("Could not find key \(Constants.FlickrResponseKeys.Title).")
                    return
                }
                
                let imageURL = URL(string: imageURLString)!
                guard let imageData = try? Data(contentsOf: imageURL) else {
                    print("Could not get image data.")
                    return
                }
                
                performUIUpdatesOnMain {
                    self.flickImageView.image = UIImage(data: imageData)
                    self.infoLabel.text = imageTitleString
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: Helper for creating a URL from parameters
    
    func flickrURLFromParameters(_ parameters: [String:Any]) -> URL {
        var components = URLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
}


//
//  Constants.swift
//  FlickFinder
//
//  Created by Jarrod Parkes on 11/5/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit

// MARK: - Constants

struct Constants {
    
    // MARK: Flickr
    struct Flickr {
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
        
        static let SearchBBoxHalfWidth = 1.0
        static let SearchBBoxHalfHeight = 1.0
        static let SearchLatRange = (-90.0, 90.0)
        static let SearchLonRange = (-180.0, 180.0)
    }
    
    // MARK: Flickr Parameter Keys
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let Text = "text"
        static let BoundingBox = "bbox"
        static let SafeSearch = "safe_search"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        // static let GalleryID = "gallery_id"
        // static let Page = "page"
        static let orderedValues = [Method, APIKey, Text, BoundingBox, SafeSearch, Extras, Format, NoJSONCallback]
    }
    
    // MARK: Flickr Parameter Values
    struct FlickrParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "91106059e4adb221703c6b0a1326a5ae" /*"YOUR API KEY HERE"*/
        static let GalleryID = "5704-72157622566655097"
        static let Text = "USER_VALUE"
        static let BoundingBox = "USER_VALUE"
        static let UseSafeSearch = "1"
        static let MediumURL = "url_m"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1" /* 1 means "yes" */
        // static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
        static let orderedValues = [SearchMethod, APIKey, Text, BoundingBox, UseSafeSearch, MediumURL, ResponseFormat, DisableJSONCallback]
    }
    
    // MARK: Flickr Response Keys
    struct FlickrResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
        static let Pages = "pages"
        static let Total = "total"
    }
    
    // MARK: Flickr Response Values
    struct FlickrResponseValues {
        static let OKStatus = "ok"
    }
    
}

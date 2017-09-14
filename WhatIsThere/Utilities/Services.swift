//
//  Services.swift
//  WhatIsThere
//
//  Created by Fomin Mykola on 9/14/17.
//  Copyright © 2017 Fomin Mykola. All rights reserved.
//

import Foundation

class DataService {
    
    static let instance = DataService()
    
    func getFickerUrl(forApiKey key: String, withAnnotation annotation: DroppablePin, andNumbersOfPhotos number: Int) -> String {
        return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(API_KEY)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
    }
}

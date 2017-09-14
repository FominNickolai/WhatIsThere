//
//  DroppablePin.swift
//  WhatIsThere
//
//  Created by Fomin Mykola on 9/14/17.
//  Copyright © 2017 Fomin Mykola. All rights reserved.
//

import UIKit
import MapKit

class DroppablePin: NSObject, MKAnnotation {
    
    dynamic var coordinate: CLLocationCoordinate2D
    var identifier: String
    
    init(coordinate: CLLocationCoordinate2D, identifier: String) {
        self.coordinate = coordinate
        self.identifier = identifier
        super.init()
    }
    
}


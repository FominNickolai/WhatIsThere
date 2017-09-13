//
//  ViewController.swift
//  WhatIsThere
//
//  Created by Fomin Mykola on 9/13/17.
//  Copyright © 2017 Fomin Mykola. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController {

    //MARK: - IBOutlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }

    //MARK: - IBActions
    
    @IBAction func centerMapButtonWasPressed(_ sender: UIButton) {
        
        
    }
    
}

//MARK: - MKMapViewDelegate
extension MapVC: MKMapViewDelegate {
    
}




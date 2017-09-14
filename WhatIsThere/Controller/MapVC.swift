//
//  ViewController.swift
//  WhatIsThere
//
//  Created by Fomin Mykola on 9/13/17.
//  Copyright © 2017 Fomin Mykola. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController {

    //MARK: - IBOutlets
    
    @IBOutlet weak var pullUpView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullUpViewHeightConstraint: NSLayoutConstraint!
    
    //MARK: - Properties
    
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 1_000
    
    var spinner: UIActivityIndicatorView?
    var progressLbl: UILabel?
    
    //MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        configureLocationServices()
        addDoubleTap()
    }

    //MARK: - IBActions
    
    @IBAction func centerMapButtonWasPressed(_ sender: UIButton) {
        
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
    
    //MARK: - Add TapGestureRecognizer to MapView
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }
    
    //MARK: - Animate ViewUp from bottom
    func animateViewUp() {
        pullUpViewHeightConstraint.constant = 300
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    //MARK: - Close PopUpView by swiping down
    func addSwipe() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        pullUpView.addGestureRecognizer(swipe)
    }
    
    //MARK: - Animate PopUpView Down
    @objc func animateViewDown() {
        pullUpViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK: - Spinner Add
    func addSpiner() {
        
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: pullUpView.bounds.width / 2 - spinner!.frame.width / 2, y: pullUpView.bounds.height / 2)
        spinner?.activityIndicatorViewStyle = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.3230867386, green: 0.3421254754, blue: 0.3874129653, alpha: 1)
        spinner?.startAnimating()
        pullUpView.addSubview(spinner!)
    }
    
    //MARK: - Add Progress Label
    func addProgressLabel() {
        progressLbl = UILabel()
        progressLbl?.frame = CGRect(x: 0, y: pullUpView.bounds.height / 2 + 25, width: pullUpView.bounds.width, height: 40)
        progressLbl?.font = UIFont(name: "Avenir Next", size: 18)
        progressLbl?.textColor = #colorLiteral(red: 0.3230867386, green: 0.3421254754, blue: 0.3874129653, alpha: 1)
        progressLbl?.textAlignment = .center
        progressLbl?.text = "12/40 Photos Loading..."
        
        pullUpView.addSubview(progressLbl!)
    }
    
    //MARK: - Remove Progress Label
    func removeProgressLabel() {
        if progressLbl != nil {
            progressLbl?.removeFromSuperview()
        }
    }
    
    //MARK: - Remove Spinner
    func removeSpinner() {
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    
}

//MARK: - MKMapViewDelegate
extension MapVC: MKMapViewDelegate {
    
    //MARK: - Customazing Pin
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation { return nil }
        
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.9771530032, green: 0.7062081099, blue: 0.1748393774, alpha: 1)
        pinAnnotation.animatesDrop = true
        return pinAnnotation
        
    }
    
    //MARK: - Center Map On User Location
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    //MARK: - Drop Pin
    @objc func dropPin(sender: UITapGestureRecognizer) {
        
        removePin()
        removeSpinner()
        removeProgressLabel()
        
        animateViewUp()
        addSwipe()
        addSpiner()
        addProgressLabel()
        
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
        mapView.addAnnotation(annotation)
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    //MARK: - Remove All current Pins
    func removePin() {
        
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
        
    }
}

//MARK: - CLLocationManagerDelegate
extension MapVC: CLLocationManagerDelegate {
    
    //MARK: - Configure Permision to Check if we can use location
    func configureLocationServices() {
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
    
}

//MARK: - UIGestureRecognizerDelegate
extension MapVC: UIGestureRecognizerDelegate {
    
}















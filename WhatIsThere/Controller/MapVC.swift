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
import Alamofire
import AlamofireImage

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
    
    var collectionView: UICollectionView?
    var collectionViewFlowLayout = UICollectionViewFlowLayout()
    
    var imageUrlArray = [String]()
    var imagesArray = [UIImage]()
    
    //MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        configureLocationServices()
        addDoubleTap()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: collectionViewFlowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        
        pullUpView.addSubview(collectionView!)
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
        cancelAllSessions()
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
        collectionView?.addSubview(spinner!)
    }
    
    //MARK: - Add Progress Label
    func addProgressLabel() {
        progressLbl = UILabel()
        progressLbl?.frame = CGRect(x: 0, y: pullUpView.bounds.height / 2 + 25, width: pullUpView.bounds.width, height: 40)
        progressLbl?.font = UIFont(name: "Avenir Next", size: 18)
        progressLbl?.textColor = #colorLiteral(red: 0.3230867386, green: 0.3421254754, blue: 0.3874129653, alpha: 1)
        progressLbl?.textAlignment = .center
        progressLbl?.text = "12/40 Photos Loading..."
        
        collectionView?.addSubview(progressLbl!)
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
    
    //MARK: - Retrieve URL For Annotation
    func retrieveUrls(forAnnotation annotation: DroppablePin, complitionHandler: @escaping (_ status: Bool) -> ()) {
        imageUrlArray = []
        
        Alamofire.request(DataService.instance.getFickerUrl(forApiKey: API_KEY, withAnnotation: annotation, andNumbersOfPhotos: 40)).responseJSON { (response) in
            
            guard let json = response.result.value as? Dictionary<String, AnyObject> else { return }
            let photosDict = json["photos"] as! Dictionary<String, AnyObject>
            let photoDictArray = photosDict["photo"] as! [Dictionary<String, AnyObject>]
            for photo in photoDictArray {
                let postUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
                self.imageUrlArray.append(postUrl)
            }
            complitionHandler(true)
        }
    }
    
    //MARK: - Retrieve Images from Flickr
    func retrieveImages(completionHandler: @escaping (_ status: Bool) -> ()) {
        imagesArray = []
        
        for url in imageUrlArray {
            Alamofire.request(url).responseImage(completionHandler: { (response) in
                guard let image = response.result.value else { return }
                self.imagesArray.append(image)
                self.progressLbl?.text = "\(self.imagesArray.count)/40 IMAGES DOWNLOADED"
                
                if self.imagesArray.count == self.imageUrlArray.count {
                    completionHandler(true)
                }
            })
        }
    }
    
    //MARK: Cancel All Sessions
    func cancelAllSessions() {
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            
            sessionDataTask.forEach({$0.cancel()})
            downloadData.forEach({$0.cancel()})
            
        }
    }
    
}

//MARK: - MKMapViewDelegate
extension MapVC: MKMapViewDelegate {
    
    //MARK: - Customizing Pin
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
        cancelAllSessions()
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
        
        retrieveUrls(forAnnotation: annotation) { (finished) in
            if finished {
                self.retrieveImages(completionHandler: { (finished) in
                    if finished {
                        //hide spinner
                        self.removeSpinner()
                        //hide label
                        self.removeProgressLabel()
                        // TODO: TODO reload collectionView
                        
                        
                    }
                })
            }
        }
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

//MARK: - UICollectionViewDataSource
extension MapVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //number of items in array
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        return cell
    }
}

//MARK: - UICollectionViewDelegate
extension MapVC: UICollectionViewDelegate {
    
}














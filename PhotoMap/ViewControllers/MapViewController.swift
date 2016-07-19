//
//  MapViewController.swift
//  PhotoMap
//
//  Created by Jason Lew on 7/15/16.
//  Copyright © 2016 Jason Lew. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    lazy var networkManager = NetworkManager()
    lazy var locationManager = LocationManager()
    let reuseIdentifier = "Photo"
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        networkManager.delegate = self
        mapView.delegate = self
        mapView.showsUserLocation = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let coordinate = CLLocationCoordinate2D(latitude: 34.01911169, longitude: -118.41033742)
        loadData(coordinate)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData(coordinate: CLLocationCoordinate2D) {
        networkManager.getPhotosByLocation(coordinate)
        updateMapLocation(coordinate)
    }
    
    func updateMapLocation(coordinate: CLLocationCoordinate2D) {
        let regionRadius: CLLocationDistance = 2000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}

// MARK: - Map Delegate
extension MapViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView: PhotoAnnotationView?
        if let aView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseIdentifier) as? PhotoAnnotationView {
            annotationView = aView
        } else {
            annotationView = PhotoAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
        }
        return annotationView
    }
}

// MARK: - Network Manager Delegate
extension MapViewController: NetworkManagerDelegate {
    func foundPhotosByLocation(photos: [Photo]) {
        mapView.addAnnotations(photos)
    }
}

// MARK: - Location Manager Delegate
extension MapViewController: LocationManagerDelegate {
    func bestEffortLocationFound(location: CLLocation) {
//        loadData(location.coordinate)
    }
}

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
    var selectedPhoto: Photo?
    var queryCoordinate: CLLocationCoordinate2D!
    var locationFound = false
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        networkManager.delegate = self
        mapView.delegate = self
        mapView.showsUserLocation = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBarHidden = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData(coordinate: CLLocationCoordinate2D) {
        networkManager.getPhotosByLocation(coordinate)
    }
    
    func updateMapLocation(coordinate: CLLocationCoordinate2D) {
        let regionRadius: CLLocationDistance = 4000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifier.showPhoto {
            if let photoVC = segue.destinationViewController as? PhotoViewController {
                photoVC.networkManager = networkManager
                photoVC.photo = selectedPhoto
            }
        }
    }
}

// MARK: - Map Delegate
extension MapViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        guard locationFound else {
            return
        }
        let newCenterCoord = mapView.region.center
        let newCenterPoint = MKMapPointForCoordinate(newCenterCoord)
        let queryPoint = MKMapPointForCoordinate(queryCoordinate)
        let distance = MKMetersBetweenMapPoints(newCenterPoint, queryPoint)
        // TODO: Get new annotations based on visible rect
        // This is a naive solution that doesn't take into account
        // the zoom factor of the map and purely relies on distance.
        // The visible rect should be used.
        if distance > Double(FlickrDefaults.radiusInKm * 1000) {
            queryCoordinate = newCenterCoord
            loadData(queryCoordinate)
        }
    }
    // TODO: Cluster annotations
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        // If it's the user location annotation, don't use the custom annotation view
        guard !annotation.isKindOfClass(MKUserLocation) else {
            return nil
        }
        guard let photoAnnotation = annotation as? Photo else {
            return nil
        }
        var annotationView: PhotoAnnotationView?
        if let aView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseIdentifier) as? PhotoAnnotationView {
            annotationView = aView
        } else {
            annotationView = PhotoAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
        }
        if let annotationView = annotationView {
            networkManager.downloadPhoto(photoAnnotation.thumbImagePath, imageView: annotationView.imageView)
        }
        
        return annotationView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let view = view as? PhotoAnnotationView,
        let photo = view.annotation as? Photo {
            selectedPhoto = photo
            mapView.deselectAnnotation(view.annotation, animated: true)
            performSegueWithIdentifier(SegueIdentifier.showPhoto, sender: self)
        }
    }
}

// MARK: - Network Manager Delegate
extension MapViewController: NetworkManagerDelegate {
    func foundPhotosByLocation(photos: [Photo]) {
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            self?.mapView.addAnnotations(photos)
        }
    }
}

// MARK: - Location Manager Delegate
extension MapViewController: LocationManagerDelegate {
    func bestEffortLocationFound(location: CLLocation) {
        locationFound = true
        queryCoordinate = location.coordinate
        updateMapLocation(queryCoordinate)
        loadData(queryCoordinate)
    }
}

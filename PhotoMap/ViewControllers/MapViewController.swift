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
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        networkManager.delegate = self
        let coordinate = CLLocationCoordinate2D(latitude: 34.022276, longitude: -118.410067)
        networkManager.getPhotosByLocation(coordinate)
        updateMapLocation(coordinate)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        
    }
    
    func updateMapLocation(coordinate: CLLocationCoordinate2D) {
        let regionRadius: CLLocationDistance = 2000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}

extension MapViewController: NetworkManagerDelegate {
    func foundPhotosByLocation(photos: [Photo]) {
        mapView.addAnnotations(photos)
    }
}

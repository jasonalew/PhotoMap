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
        networkManager.getPhotosByLocation(34.022276, lon: -118.410067)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func loadData() {
        
    }
}

extension MapViewController: NetworkManagerDelegate {
    func foundPhotosByLocation(basePhotos: [BasePhoto]) {
        networkManager.getLocationForPhotos(basePhotos)
    }
    func addedCoordinatesToPhotos(photos: [Photo]) {
        dlog(photos)
    }
}

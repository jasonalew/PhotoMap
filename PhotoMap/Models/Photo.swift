//
//  Photo.swift
//  PhotoMap
//
//  Created by Jason Lew on 7/15/16.
//  Copyright © 2016 Jason Lew. All rights reserved.
//

import Foundation
import MapKit

class Photo: NSObject, MKAnnotation {
    let id: String
    let farm: Int
    let server: String
    let secret: String
    let title: String?
    let coordinate: CLLocationCoordinate2D
    var imagePath: String?
    
    override var description: String {
        return "\(self.dynamicType): Id: \(id), Farm: \(farm), Server: \(server), Secret: \(secret), Title: \(title), Latitude: \(coordinate.latitude), Longitude: \(coordinate.longitude)."
    }
    
    init(id: String, farm: Int, server: String, secret: String, title: String?, coordinate: CLLocationCoordinate2D) {
        self.id = id
        self.farm = farm
        self.server = server
        self.secret = secret
        self.title = title
        self.coordinate = coordinate
        super.init()
        self.imagePath = flickrImagePath(self, size: FlickrImageSize.largeThumb)
    }
    
    class func parsePhotoJson(json: [String: AnyObject]) -> [Photo]? {
        if let photoJson = json["photos"] as? [String: AnyObject],
        let photos = photoJson[Flickr.photo] as? [[String: AnyObject]] {
            var photosNearby = [Photo]()
            for photo in photos {
                if let id = photo[Flickr.id] as? String,
                    let farm = photo[Flickr.farm] as? Int,
                    let server = photo[Flickr.server] as? String,
                    let secret = photo[Flickr.secret] as? String,
                    let latitude = photo[Flickr.latitude] as? String,
                    let longitude = photo[Flickr.longitude] as? String,
                    let coordinate = Photo.convertToLocation(latitude, longitude: longitude) {
                    let title = photo[Flickr.title] as? String
                    let newPhoto = Photo(id: id, farm: farm, server: server, secret: secret, title: title, coordinate: coordinate)
                    photosNearby.append(newPhoto)
                }
            }
            return photosNearby
        } else {
            return nil
        }
    }
    
    class func parseLocationJson(json: [String: AnyObject]) -> CLLocationCoordinate2D? {
        if let photoJson = json[Flickr.photo] as? [String: AnyObject],
        let location = photoJson[Flickr.location] as? [String: AnyObject],
        let latitude = location[Flickr.latitude] as? String,
        let longitude = location[Flickr.longitude] as? String {
            return convertToLocation(latitude, longitude: longitude)
        } else {
            return nil
        }
    }
    
    class func convertToLocation(latitude: String, longitude: String) -> CLLocationCoordinate2D? {
        if let latitude = Double(latitude), let longitude = Double(longitude) {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        return nil
    }
}
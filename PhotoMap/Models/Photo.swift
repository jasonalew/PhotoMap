//
//  Photo.swift
//  PhotoMap
//
//  Created by Jason Lew on 7/15/16.
//  Copyright © 2016 Jason Lew. All rights reserved.
//

import Foundation
import MapKit

struct BasePhoto {
    let id: String
    let farm: Int
    let server: String
    let secret: String
    let title: String?
    
    init(id: String, farm: Int, server: String, secret: String, title: String?) {
        self.id = id
        self.farm = farm
        self.server = server
        self.secret = secret
        self.title = title
    }
}

class Photo: NSObject, MKAnnotation {
    var title: String?
    let coordinate: CLLocationCoordinate2D
    let basePhoto: BasePhoto
    
    override var description: String {
        return "\(self.dynamicType): Id: \(basePhoto.id), Farm: \(basePhoto.farm), Server: \(basePhoto.server), Secret: \(basePhoto.secret), Title: \(basePhoto.title), Latitude: \(coordinate.latitude), Longitude: \(coordinate.longitude)."
    }
    
    // Flickr's API requires a call to get the photos based on location and then
    // a second call to get the coordinates from the photo id, so we'll first create
    // a struct with the base info and then create a class instance when we have the coordinates.
    init(basePhoto: BasePhoto, coordinate: CLLocationCoordinate2D) {
        self.basePhoto = basePhoto
        self.title = basePhoto.title
        self.coordinate = coordinate
    }
    
    class func parsePhotoJson(json: [String: AnyObject]) -> [BasePhoto]? {
        if let photoJson = json["photos"] as? [String: AnyObject],
        let photos = photoJson[Flickr.photo] as? [[String: AnyObject]] {
            var photosNearby = [BasePhoto]()
            for photo in photos {
                if let id = photo[Flickr.id] as? String,
                    let farm = photo[Flickr.farm] as? Int,
                    let server = photo[Flickr.server] as? String,
                    let secret = photo[Flickr.secret] as? String {
                    let title = photo[Flickr.title] as? String
                    let newBasePhoto = BasePhoto(id: id, farm: farm, server: server, secret: secret, title: title)
                    photosNearby.append(newBasePhoto)
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
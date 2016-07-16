//
//  Photo.swift
//  PhotoMap
//
//  Created by Jason Lew on 7/15/16.
//  Copyright © 2016 Jason Lew. All rights reserved.
//

import Foundation

class Photo: CustomStringConvertible {
    let id: String
    let farm: Int
    let server: String
    let secret: String
    var title: String?
    var latitude: Float?
    var longitude: Float?
    
    var description: String {
        return "\(self.dynamicType): Id: \(id), Farm: \(farm), Server: \(server), Secret: \(secret), Title: \(title), Latitude: \(latitude), Longitude: \(longitude)."
    }
    
    init(id: String, farm: Int, server: String, secret: String) {
        self.id = id
        self.farm = farm
        self.server = server
        self.secret = secret
    }
    
    class func parseJson(json: [String: AnyObject]) -> [String: Photo]? {
        if let photoJson = json["photos"] as? [String: AnyObject],
        let photos = photoJson["photo"] as? [[String: AnyObject]] {
            
            var photosNearby = [String: Photo]()
            for photo in photos {
                if let id = photo[Flickr.id] as? String,
                    let farm = photo[Flickr.farm] as? Int,
                    let server = photo[Flickr.server] as? String,
                    let secret = photo[Flickr.secret] as? String {
                    
                    let newPhoto = Photo(id: id, farm: farm, server: server, secret: secret)
                    newPhoto.title = photo[Flickr.title] as? String
                    photosNearby[id] = newPhoto
                }
            }
            return photosNearby
        } else {
            return nil
        }
    }
    
    func addLocation(latitude: Float, longitude: Float) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
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
    
    struct FlickrId {
        let id: String
        let farm: Int
        let server: String
        let secret: String
        
        init(id: String, farm: Int, server: String, secret: String) {
            self.id = id
            self.farm = farm
            self.server = server
            self.secret = secret
        }
    }
    
    struct FlickrMetadata {
        let tags: [String]?
        let ownerName: String?
        let dateTaken: String?
        let description: String?
        
        init(tags: [String]?, ownerName: String?, dateTaken: String?, description: String?) {
            self.tags = tags
            self.ownerName = ownerName
            self.dateTaken = dateTaken
            self.description = description
        }
    }
    
    // MARK: - Properties
    let flickrId: FlickrId
    let flickrMetadata: FlickrMetadata
    let title: String?
    let coordinate: CLLocationCoordinate2D
    var thumbImagePath: String?
    var fullSizeImagePath: String?
    
    override var description: String {
        return "\(type(of: self)): FlickrId: \(flickrId), Title: \(title), Tags: \(flickrMetadata.tags), OwnerName: \(flickrMetadata.ownerName), Description: \(flickrMetadata.description), DateTaken: \(flickrMetadata.dateTaken) Latitude: \(coordinate.latitude), Longitude: \(coordinate.longitude)."
    }
    // MARK: - Init
    init(flickrId: FlickrId, flickrMetadata: FlickrMetadata, title: String?, coordinate: CLLocationCoordinate2D) {
        self.flickrId = flickrId
        self.flickrMetadata = flickrMetadata
        self.title = title
        self.coordinate = coordinate
        super.init()
        self.thumbImagePath = flickrImagePath(self, size: FlickrImageSize.smallThumb)
        self.fullSizeImagePath = flickrImagePath(self, size: FlickrImageSize.large)
        dlog(self)
    }
    // MARK: - Parse and helpers
    class func parsePhotoJson(_ json: [String: AnyObject]) -> [Photo]? {
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
                    let ownerName = photo[Flickr.ownername] as? String
                    let dateTaken = photo[Flickr.datetaken] as? String
                    var description = ""
                    if let desc = photo[Flickr.description] as? [String: AnyObject],
                        let descString = desc[Flickr.content] as? String {
                        description = descString
                    }
                    let tagString = photo[Flickr.tags] as? String
                    // Flickr tags come as a space separated String
                    let tags = tagString?.components(separatedBy: " ")
                    
                    let flickrId = FlickrId(id: id, farm: farm, server: server, secret: secret)
                    let flickrMetadata = FlickrMetadata(tags: tags, ownerName: ownerName, dateTaken: dateTaken, description: description)
                    let newPhoto = Photo(flickrId: flickrId, flickrMetadata: flickrMetadata, title: title, coordinate: coordinate)
                    photosNearby.append(newPhoto)
                }
            }
            return photosNearby
        } else {
            return nil
        }
    }
    
    class func parseLocationJson(_ json: [String: AnyObject]) -> CLLocationCoordinate2D? {
        if let photoJson = json[Flickr.photo] as? [String: AnyObject],
        let location = photoJson[Flickr.location] as? [String: AnyObject],
        let latitude = location[Flickr.latitude] as? String,
        let longitude = location[Flickr.longitude] as? String {
            return convertToLocation(latitude, longitude: longitude)
        } else {
            return nil
        }
    }
    
    class func convertToLocation(_ latitude: String, longitude: String) -> CLLocationCoordinate2D? {
        if let latitude = Double(latitude), let longitude = Double(longitude) {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        return nil
    }
}

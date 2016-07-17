//
//  Constants.swift
//  PhotoMap
//
//  Created by Jason Lew on 7/15/16.
//  Copyright © 2016 Jason Lew. All rights reserved.
//

import Foundation

struct Flickr {
    static let method = "method"
    static let photo = "photo"
    static let location = "location"
    static let lat = "lat"
    static let lon = "lon"
    static let extras = "extras"
    static let geo = "geo"
    static let latitude = "latitude"
    static let longitude = "longitude"
    static let photoId = "photo_id"
    static let title = "title"
    static let id = "id"
    static let farm = "farm"
    static let server = "server"
    static let secret = "secret"
    static let photosSearch = "flickr.photos.search"
    static let geoLocation = "flickr.photos.geo.getLocation"
}

// MARK: - Functions
func dlog(items: Any, filePath: String = #file, function: String = #function) {
    var className = ""
    if let rangeOfSlash = filePath.rangeOfString("/", options: .BackwardsSearch, range: nil, locale: nil) {
        className = String(filePath.characters.suffixFrom(rangeOfSlash.endIndex))
    }
    #if DEBUG
        Swift.print("\(className) - \(function) - \(items)\n")
    #endif
}
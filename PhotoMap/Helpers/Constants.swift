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
    static let lat = "lat"
    static let lon = "lon"
    static let photoId = "photo_id"
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
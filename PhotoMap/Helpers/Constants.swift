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
    static let per_page = "per_page"
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

enum FlickrImageSize: String {
    case smallThumb = "s"
    case largeThumb = "q"
    case small = "n" // 320 on longest side
    case medium = "z" // 640 on longest side
    case medLarge = "c" // 800 on longest side
    case large = "b" // 1024 on longest side
    case xl = "k" // 2048 on longest side
    case original = "o"
}

func flickrImagePath(photo: Photo, size: FlickrImageSize) -> String {
    return "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_\(size.rawValue).jpg"
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
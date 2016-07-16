//
//  Router.swift
//  PhotoMap
//
//  Created by Jason Lew on 7/14/16.
//  Copyright © 2016 Jason Lew. All rights reserved.
//

import Foundation

protocol UrlRequest {
    static var baseUrlPath: String {get}
    var urlRequest: NSMutableURLRequest {get}
}

enum Encoding {
    case Url
    case JSON
    
    func encodedURLRequest(request: NSMutableURLRequest, parameters: [String: AnyObject]) -> NSMutableURLRequest {
        switch self {
        case .Url:
            // Add the parameters to the url query
            let urlComponents = NSURLComponents(URL: request.URL!, resolvingAgainstBaseURL: false)
            var queryItems = [NSURLQueryItem]()
            for (key, value) in parameters {
                if let value = ("\(value)").stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLPathAllowedCharacterSet()) {
                    queryItems.append(NSURLQueryItem(name: key, value: value))
                }
            }
            urlComponents?.queryItems = queryItems
            request.URL = urlComponents?.URL
        case .JSON:
            // Add JSON to the request HTTPBody
            do {
                let jsonData = try NSJSONSerialization.dataWithJSONObject(parameters, options: .PrettyPrinted)
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                request.HTTPBody = jsonData
            } catch let error as NSError {
                dlog("Error creating JSON: \(error.localizedDescription)")
            }
        }
        return request
    }
}

enum HTTPMethod: String {
    case POST, GET, PUT, DELETE
}

enum Router {
    case GeoQuery(lat: Float, lon: Float)
    case GetGeoLocation(photoId: String)
}

struct Keys {
    static let flickrApi = "flickrApiKey"
}

extension Router: UrlRequest {
    // Load the API key from the plist
    static var baseUrlPath: String {
        return "https://api.flickr.com/services/rest/"
    }
    
    var flickrApiKey: String {
        // WARNING: Obtain an API key and add it to Network.plist with key: "flickrApiKey"
        let apiPath = NSBundle.mainBundle().pathForResource("Network", ofType: "plist")
        let apiDict = NSDictionary(contentsOfFile: apiPath!)
        return apiDict![Keys.flickrApi] as! String
    }
    
    var urlRequest: NSMutableURLRequest {
        let result: (path: String, method: HTTPMethod, parameters: [String: AnyObject]) = {
            // These are the common parameters that are needed in all calls
            var parameters: [String: AnyObject] = [
                "format": "json",
                "nojsoncallback": "1",
                "radius": "0.1",
                "radius_units": "km",
                "api_key": flickrApiKey
            ]
            switch self {
            case GeoQuery(let lat, let lon):
                let newParameters: [String: AnyObject] = [Flickr.method: Flickr.photosSearch, Flickr.lat: lat, Flickr.lon: lon]
                for (key, value) in newParameters {
                    parameters[key] = value
                }
                return ("", .GET, parameters)
            case GetGeoLocation(let photoId):
                let newParameters: [String: AnyObject] = [Flickr.method: Flickr.geoLocation, Flickr.photoId: photoId]
                for (key, value) in newParameters {
                    parameters[key] = value
                }
                return ("", .GET, parameters)
            }
        }()
        
        let url = NSURL(string: Router.baseUrlPath)!
        let urlRequest = NSMutableURLRequest(URL: url.URLByAppendingPathComponent(result.path))
        urlRequest.HTTPMethod = result.method.rawValue
        urlRequest.timeoutInterval = 20
        return Encoding.Url.encodedURLRequest(urlRequest, parameters: result.parameters)
        
    }
}

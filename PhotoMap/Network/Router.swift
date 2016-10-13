//
//  Router.swift
//  PhotoMap
//
//  Created by Jason Lew on 7/14/16.
//  Copyright © 2016 Jason Lew. All rights reserved.
//

import Foundation
import MapKit

protocol UrlRequest {
    static var baseUrlPath: String {get}
    var urlRequest: NSMutableURLRequest {get}
}

enum Encoding {
    case url
    case json
    
    func encodedURLRequest(_ request: NSMutableURLRequest, parameters: [String: Any]) -> NSMutableURLRequest {
        switch self {
        case .url:
            // Add the parameters to the url query
            var urlComponents = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)
            var queryItems = [URLQueryItem]()
            for (key, value) in parameters {
                var currentValue: Any
                // If it's an array of values, join them by a comma before encoding
                if let valueArray = value as? [AnyObject] {
                    currentValue = (valueArray.flatMap{String(describing: $0)}).joined(separator: ",") as AnyObject
                } else {
                    currentValue = value
                }
                if let value = ("\(currentValue)").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed) {
                    queryItems.append(URLQueryItem(name: key, value: value))
                }
            }
            urlComponents?.queryItems = queryItems
            request.url = urlComponents?.url
            dlog("Query: \(request.url)")
        case .json:
            // Add JSON to the request HTTPBody
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                request.httpBody = jsonData
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
    case geoQuery(coordinate: CLLocationCoordinate2D)
    case getGeoLocation(photoId: String)
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
        let apiPath = Bundle.main.path(forResource: "Network", ofType: "plist")
        let apiDict = NSDictionary(contentsOfFile: apiPath!)
        return apiDict![Keys.flickrApi] as! String
    }
    
    var urlRequest: NSMutableURLRequest {
        let result: (path: String, method: HTTPMethod, parameters: [String: Any]) = {
            // These are the common parameters that are needed in all calls
            var parameters: [String: Any] = [
                "format": "json" as AnyObject,
                "nojsoncallback": "1" as AnyObject,
                "radius": "\(FlickrDefaults.radiusInKm)" as AnyObject,
                "radius_units": "km" as AnyObject,
                "api_key": flickrApiKey as AnyObject
            ]
            switch self {
            case .geoQuery(let coordinate):
                let newParameters: [String: Any] = [
                    Flickr.method: Flickr.photosSearch as AnyObject,
                    Flickr.lat: coordinate.latitude as AnyObject,
                    Flickr.lon: coordinate.longitude as AnyObject,
                    Flickr.extras: [
                        Flickr.geo,
                        Flickr.tags,
                        Flickr.description,
                        Flickr.owner_name,
                        Flickr.date_taken
                    ],
                    Flickr.per_page: 40
                ]
                for (key, value) in newParameters {
                    parameters[key] = value
                }
                return ("", .GET, parameters)
            case .getGeoLocation(let photoId):
                let newParameters: [String: AnyObject] = [
                    Flickr.method: Flickr.geoLocation as AnyObject,
                    Flickr.photoId: photoId as AnyObject
                ]
                for (key, value) in newParameters {
                    parameters[key] = value
                }
                return ("", .GET, parameters)
            }
        }()
        
        let url = URL(string: Router.baseUrlPath)!
        let urlRequest = NSMutableURLRequest(url: url.appendingPathComponent(result.path))
        urlRequest.httpMethod = result.method.rawValue
        urlRequest.timeoutInterval = 20
        return Encoding.url.encodedURLRequest(urlRequest, parameters: result.parameters) 
    }
}

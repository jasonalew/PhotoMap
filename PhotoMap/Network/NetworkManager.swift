//
//  NetworkManager.swift
//  PhotoMap
//
//  Created by Jason Lew on 7/15/16.
//  Copyright © 2016 Jason Lew. All rights reserved.
//

import UIKit

protocol NetworkManagerDelegate: class {
    func foundPhotosByLocation(photos: [String: Photo])
    func foundGeoLocation(id: String, latitude: Float, longitude: Float)
}

class NetworkManager {
    
    weak var delegate: NetworkManagerDelegate?
    let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    private func showNetworkActivityIndicator(shouldShow: Bool) {
        dispatch_async(dispatch_get_main_queue()) { 
            UIApplication.sharedApplication().networkActivityIndicatorVisible = shouldShow
        }
    }
    
    func getPhotosByLocation(lat: Float, lon: Float) {
        showNetworkActivityIndicator(true)
        let task = defaultSession.dataTaskWithRequest(Router.GeoQuery(lat: lat, lon: lon).urlRequest) { [weak self](data, response, error) in
            if let error = error {
                dlog(error.localizedDescription)
                self?.showNetworkActivityIndicator(false)
                return
            } else if let httpResponse = response as? NSHTTPURLResponse {
                guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 400 else {
                    dlog("Invalid server response")
                    self?.showNetworkActivityIndicator(false)
                    return
                }
                guard let data = data else {
                    dlog("Couldn't get data")
                    self?.showNetworkActivityIndicator(false)
                    return
                }
                do {
                    if let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject] {
                        if let photos = Photo.parseJson(json),
                        let delegate = self?.delegate {
                            delegate.foundPhotosByLocation(photos)
                        }
                    }
                    self?.showNetworkActivityIndicator(false)
                } catch let error as NSError {
                    dlog(error.localizedDescription)
                    self?.showNetworkActivityIndicator(false)
                }
            }
        }
        task.resume()
    }
}

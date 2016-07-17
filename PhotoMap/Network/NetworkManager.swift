//
//  NetworkManager.swift
//  PhotoMap
//
//  Created by Jason Lew on 7/15/16.
//  Copyright © 2016 Jason Lew. All rights reserved.
//

import UIKit
import MapKit

protocol NetworkManagerDelegate: class {
    func foundPhotosByLocation(basePhotos: [BasePhoto])
    func addedCoordinatesToPhotos(photos: [Photo])
}

class NetworkManager {
    
    weak var delegate: NetworkManagerDelegate?
    
    let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    private func showNetworkActivityIndicator(shouldShow: Bool) {
        dispatch_async(dispatch_get_main_queue()) { 
            UIApplication.sharedApplication().networkActivityIndicatorVisible = shouldShow
        }
    }
    
    func getPhotosByLocation(coordinate: CLLocationCoordinate2D) {
        showNetworkActivityIndicator(true)
        let task = defaultSession.dataTaskWithRequest(Router.GeoQuery(coordinate: coordinate)
            .urlRequest) { [weak self](data, response, error) in
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
                        if let photos = Photo.parsePhotoJson(json),
                        let strongSelf = self {
                            strongSelf.delegate?.foundPhotosByLocation(photos)
                        }
                    }
                } catch let error as NSError {
                    dlog(error.localizedDescription)
                    self?.showNetworkActivityIndicator(false)
                }
            }
        }
        task.resume()
        showNetworkActivityIndicator(false)
    }
    
    func getLocationForPhotos(basePhotos: [BasePhoto]) {
        showNetworkActivityIndicator(true)
        var photos = [Photo]()
        for (index, basePhoto) in basePhotos.enumerate() {
            let task = defaultSession.dataTaskWithRequest(Router.GetGeoLocation(photoId: basePhoto.id).urlRequest, completionHandler: { [weak self](data, response, error) in
                if let error = error {
                    dlog(error.localizedDescription)
                    self?.showNetworkActivityIndicator(false)
                    return
                } else if let response = response as? NSHTTPURLResponse {
                    guard response.statusCode >= 200 && response.statusCode < 400 else {
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
                        if let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject],
                        let coordinate = Photo.parseLocationJson(json) {
                            
                            let photo = Photo(basePhoto: basePhoto, coordinate: coordinate)
                            photos.append(photo)
                            dispatch_async(dispatch_get_main_queue(), { 
                                if index == basePhotos.count - 1 {
                                    if let strongSelf = self {
                                        strongSelf.delegate?.addedCoordinatesToPhotos(photos)
                                    }
                                }
                            })
                            
                        }
                        
                    } catch let error as NSError {
                        dlog(error.localizedDescription)
                        self?.showNetworkActivityIndicator(false)
                    }
                }
            })
            task.resume()
        }
        showNetworkActivityIndicator(false)
    }
}

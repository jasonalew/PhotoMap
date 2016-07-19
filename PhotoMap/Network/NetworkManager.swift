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
    func foundPhotosByLocation(basePhotos: [Photo])
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
                    self?.showNetworkActivityIndicator(false)
                } catch let error as NSError {
                    dlog(error.localizedDescription)
                    self?.showNetworkActivityIndicator(false)
                }
            }
        }
        task.resume()
    }
    
    func downloadPhoto(path: String?, imageView: UIImageView? = nil) {
        var image: UIImage?
        guard let path = path,
            let url = NSURL(string: path) else {
            return
        }
        showNetworkActivityIndicator(true)
        let downloadTask = defaultSession.downloadTaskWithURL(url) { [weak imageView, weak self](url, response, error) in
            if let error = error {
                dlog(error.localizedDescription)
                self?.showNetworkActivityIndicator(false)
                return
            } else {
                guard let httpResponse = response as? NSHTTPURLResponse where
                    httpResponse.statusCode >= 200 && httpResponse.statusCode < 400 else {
                        self?.showNetworkActivityIndicator(false)
                    return
                }
                guard let url = url else {
                    self?.showNetworkActivityIndicator(false)
                    return
                }
                
                if let data = NSData(contentsOfURL: url),
                    let imgDataProvider = CGDataProviderCreateWithCFData(data),
                    let cgImage = CGImageCreateWithJPEGDataProvider(imgDataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault) {
                    image = UIImage(CGImage: cgImage)
                    if let imageView = imageView {
                        dispatch_async(dispatch_get_main_queue(), { 
                            imageView.image = image
                        })
                    }
                }
                self?.showNetworkActivityIndicator(false)
            }
        }
        downloadTask.resume()
    }
}

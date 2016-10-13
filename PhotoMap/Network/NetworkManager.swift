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
    func foundPhotosByLocation(_ basePhotos: [Photo])
}

class NetworkManager {
    
    weak var delegate: NetworkManagerDelegate?
    
    let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
    
    var imageCache = [String: UIImage]()
    let maxImageCache = 80
    
    fileprivate func showNetworkActivityIndicator(_ shouldShow: Bool) {
        DispatchQueue.main.async { 
            UIApplication.shared.isNetworkActivityIndicatorVisible = shouldShow
        }
    }
    
    fileprivate func addToImageCache(_ path: String, image: UIImage?) {
        // If we are at max capacity for the cache, remove the first entry
        if imageCache.count >= maxImageCache {
            imageCache.remove(at: imageCache.startIndex)
        }
        imageCache[path] = image
    }
    
    func getPhotosByLocation(_ coordinate: CLLocationCoordinate2D) {
        showNetworkActivityIndicator(true)
        let task = defaultSession.dataTask(with: Router.geoQuery(coordinate: coordinate)
            .urlRequest as URLRequest, completionHandler: { [weak self](data, response, error) in
            if let error = error {
                dlog(error.localizedDescription)
                self?.showNetworkActivityIndicator(false)
                return
            } else if let httpResponse = response as? HTTPURLResponse {
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
                    if let json = try JSONSerialization.jsonObject(
                        with: data, options: []) as? [String: AnyObject] {
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
        }) 
        task.resume()
    }
    
    func downloadPhoto(_ path: String?, imageView: UIImageView? = nil, noCache: Bool = false) {
        var image: UIImage?
        guard let path = path,
            let url = URL(string: path) else {
            return
        }
        // Check if we have a cached image first
        if let cachedImage = imageCache[path],
        let imageView = imageView {
            DispatchQueue.main.async(execute: { 
                imageView.image = cachedImage
                dlog("Cached image found for path: \(path)")
            })
        } else {
            showNetworkActivityIndicator(true)
            let downloadTask = defaultSession.downloadTask(with: url, completionHandler: {
                [weak imageView, weak self](url, response, error) in
                if let error = error {
                    dlog(error.localizedDescription)
                    self?.showNetworkActivityIndicator(false)
                    return
                } else {
                    guard let httpResponse = response as? HTTPURLResponse ,
                        httpResponse.statusCode >= 200 && httpResponse.statusCode < 400 else {
                            self?.showNetworkActivityIndicator(false)
                            return
                    }
                    guard let url = url else {
                        self?.showNetworkActivityIndicator(false)
                        return
                    }
                    
                    if let data = try? Data(contentsOf: url),
                        let imgDataProvider = CGDataProvider(data: data as CFData),
                        let cgImage = CGImage(
                            jpegDataProviderSource: imgDataProvider, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent) {
                        image = UIImage(cgImage: cgImage)
                        if let imageView = imageView {
                            DispatchQueue.main.async(execute: {
                                imageView.image = image
                                if !noCache {
                                    self?.addToImageCache(path, image: image)
                                }
                            })
                        }
                    }
                    self?.showNetworkActivityIndicator(false)
                }
            }) 
            downloadTask.resume()
        }
        
    }
}

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

enum NetworkError: Error {
    case InvalidServerResponse
    case InvalidData
}

class NetworkManager {
    // MARK: - Properties
    weak var delegate: NetworkManagerDelegate?
    
    let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
    
    var imageCache = URLCache()
    
    // MARK: - Functions
    
    fileprivate func showNetworkActivityIndicator(_ shouldShow: Bool) {
        DispatchQueue.main.async { 
            UIApplication.shared.isNetworkActivityIndicatorVisible = shouldShow
        }
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
                    self?.showNetworkActivityIndicator(false)
                    dlog(NetworkError.InvalidServerResponse)
                    return
                }
                guard let data = data else {
                    dlog(NetworkError.InvalidData)
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
        guard let path = path,
            let photoUrl = URL(string: path) else {
            return
        }
        
        // Check if we have a cached image first
        let request = URLRequest(url: photoUrl)
        if let cachedResponse = imageCache.cachedResponse(for: request),
        let imageView = imageView {
            DispatchQueue.main.async(execute: {
                imageView.image = self.imageFrom(data: cachedResponse.data)
                dlog("Cached image found for path: \(path)")
            })
        } else {
            showNetworkActivityIndicator(true)
            let downloadTask = defaultSession.downloadTask(with: photoUrl, completionHandler: {
                [weak imageView, weak self](url, response, error) in
                if let error = error {
                    dlog(error.localizedDescription)
                    self?.showNetworkActivityIndicator(false)
                    return
                } else {
                    guard let response = response,
                    let httpResponse = response as? HTTPURLResponse,
                        httpResponse.statusCode >= 200 && httpResponse.statusCode < 400 else {
                            self?.showNetworkActivityIndicator(false)
                            return
                    }
                    guard let downloadUrl = url else {
                        self?.showNetworkActivityIndicator(false)
                        return
                    }
                    
                    if let data = try? Data(contentsOf: downloadUrl),
                        let image = self?.imageFrom(data: data),
                        let imageView = imageView {
                            DispatchQueue.main.async(execute: {
                                imageView.image = image
                                if !noCache {
                                    // Add the response to the cache
                                    let cachedResponse = CachedURLResponse(response: response, data: data)
                                    self?.imageCache.storeCachedResponse(cachedResponse, for: URLRequest(url: photoUrl))
                                }
                            })
                    }
                    self?.showNetworkActivityIndicator(false)
                }
            }) 
            downloadTask.resume()
        }
    }
    
    func imageFrom(data: Data) -> UIImage? {
        if let imgDataProvider = CGDataProvider(data: data as CFData),
        let cgImage = CGImage(
        jpegDataProviderSource: imgDataProvider, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
}

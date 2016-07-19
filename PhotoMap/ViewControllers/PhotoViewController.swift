//
//  PhotoViewController.swift
//  PhotoMap
//
//  Created by Jason Lew on 7/18/16.
//  Copyright © 2016 Jason Lew. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {
    var photo: Photo!
    var networkManager: NetworkManager!

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let photoTitle = photo.title {
            title = photoTitle
        }
        
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        networkManager.downloadPhoto(photo.fullSizeImagePath, imageView: imageView)
    }

}

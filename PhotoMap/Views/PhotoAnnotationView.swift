//
//  PhotoAnnotationView.swift
//  PhotoMap
//
//  Created by Jason Lew on 7/18/16.
//  Copyright © 2016 Jason Lew. All rights reserved.
//

import UIKit
import MapKit

class PhotoAnnotationView: MKAnnotationView {
    struct Margin {
        static let standard: CGFloat = 2.0
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.whiteColor()
        self.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        if let annotation = annotation as? Photo,
        let path = annotation.imagePath,
            let url = NSURL(string: path),
        let data = NSData(contentsOfURL: url),
        let image = UIImage(data: data) {
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: Margin.standard, y: Margin.standard, width: self.frame.width - 2 * Margin.standard, height: self.frame.height - 2 * Margin.standard)
            self.addSubview(imageView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

}

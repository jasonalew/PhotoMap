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
    struct Layout {
        static let marginStandard: CGFloat = 2.0
        static let annotationEdge: CGFloat = 60
    }
    
    lazy var imageView = UIImageView()
    var fullSizeImagePath: String?

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.white
        self.frame = CGRect(x: 0, y: 0, width: Layout.annotationEdge, height: Layout.annotationEdge)
        imageView.frame = CGRect(x: Layout.marginStandard,
                                 y: Layout.marginStandard,
                                 width: self.frame.width - 2 * Layout.marginStandard,
                                 height: self.frame.height - 2 * Layout.marginStandard)
        self.addSubview(imageView)
    }
    
    override func prepareForReuse() {
        imageView.image = nil
        fullSizeImagePath = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}

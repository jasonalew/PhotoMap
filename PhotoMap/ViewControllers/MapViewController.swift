//
//  MapViewController.swift
//  PhotoMap
//
//  Created by Jason Lew on 7/15/16.
//  Copyright © 2016 Jason Lew. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()

        let request = Router.GeoQuery(lat: 34.022276, lon: -118.410067).urlRequest
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            guard let data = data else {
                return
            }
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options:[]) as? [String: AnyObject]
                dlog("json: \(json)")
                
            } catch let error as NSError {
                dlog("Can't get JSON: \(error.localizedDescription)")
            }
        }
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

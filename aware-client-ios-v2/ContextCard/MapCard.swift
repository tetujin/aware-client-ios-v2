//
//  MapContextCardView.swift
//  Vita
//
//  Created by Yuuki Nishiyama on 2018/06/24.
//  Copyright © 2018 Yuuki Nishiyama. All rights reserved.
//

import UIKit
import MapKit
import AWAREFramework

class MapCard: ContextCard {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var mapView:MKMapView?
    
    override func setup() {
        super.setup()
        let chartHeight = frame.height - titleLabel.frame.height - spaceView.frame.height
        mapView = MKMapView.init(frame:CGRect(x:0, y:0, width:0, height:chartHeight))
        if let mv = mapView{
            mv.isHidden = true
            self.translatesAutoresizingMaskIntoConstraints = false
            self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
            self.spaceView.translatesAutoresizingMaskIntoConstraints = false
            self.baseStackView.insertArrangedSubview(mv, at: 1)
        }
    }
    
    func setMap(locationSensor:Locations) {
        activityIndicatorView.isHidden = false;
        
        self.titleLabel.text = locationSensor.getName()
        if let storage = locationSensor.storage {
            storage.fetchTodaysData(handler: { (name, results, start, end, error) in
                DispatchQueue.main.sync {
                    if let mv = self.mapView{
                        self.indicatorView.isHidden = true
                        mv.isHidden = false
                        
                        for result in results as! Array<Dictionary<String, Any>> {
                            // double_latitude
                            // double_longitude
                            let latitude = result["double_latitude"] as! Double?
                            let longitude = result["double_longitude"] as! Double?
                            // show artwork on map
                            let item = MKPointAnnotation.init()
                            item.coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
                            mv.addAnnotation(item)
                        }
                        mv.showAnnotations(mv.annotations, animated: true)
                    }
                }
            })
        }        
    }
}

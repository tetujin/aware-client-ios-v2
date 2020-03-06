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

class MapCard: ContextCard{

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var mapView:MKMapView?
    var polyline:MKPolyline?
    var render:MKPolylineRenderer?
    
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
            mv.delegate = self
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
                        
                        var mapPoints:[CLLocationCoordinate2D] = Array()
                        
                        for result in results as! Array<Dictionary<String, Any>> {
                            // double_latitude
                            // double_longitude
                            let latitude = result["double_latitude"] as! Double?
                            let longitude = result["double_longitude"] as! Double?
                            // show artwork on map
                            let loc = CLLocationCoordinate2DMake(latitude!, longitude!)
                            
                            let item = MKPointAnnotation()
                            item.coordinate = loc
                            mv.addAnnotation(item)
                            
                            mapPoints.append(loc)
                        }
                         mv.showAnnotations(mv.annotations, animated: true)
                        
                        // remove a previous polyline
                        if let polyline = self.polyline {
                            self.mapView?.removeOverlay(polyline)
                        }
                        
                        // create a polyline with all cooridnates
                        self.polyline = MKPolyline(coordinates:mapPoints, count: mapPoints.count)
                        // set the created polyline
                        if let polyline = self.polyline {
                            self.mapView?.addOverlay(polyline)
                        }
                    }
                }
            })
        }        
    }
}

extension MapCard: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        self.render = MKPolylineRenderer(overlay: overlay)
        self.render?.lineWidth = 5
        self.render?.strokeColor = .gray
        return self.render!
    }
}

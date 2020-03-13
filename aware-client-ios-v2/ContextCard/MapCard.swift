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
    var polyline:MyPolyline?
    var render:MKPolylineRenderer?
    
    var lastLocation:CLLocationCoordinate2D?
    
    override func setup() {
        super.setup()
        let chartHeight = 0 //  frame.height - titleLabel.frame.height - spaceView.frame.height
        mapView = MKMapView.init(frame:CGRect(x:0, y:0, width:0, height:chartHeight))
        if let mv = mapView{
            mv.isHidden = true
            self.translatesAutoresizingMaskIntoConstraints = false
            self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
            self.spaceView.translatesAutoresizingMaskIntoConstraints = false
            /// insert the chart-view into the bottom of navigation-view
            self.baseStackView.insertArrangedSubview(mv, at: 2)
            mv.delegate = self
        }
    }
    
    func setMap(locationSensor:Locations) {
        activityIndicatorView.isHidden = false;
        
        self.titleLabel.text = locationSensor.getName()
        if let storage = locationSensor.storage {
            storage.fetchTodaysData(handler: { (name, results, start, end, error) in
                DispatchQueue.main.sync {
                    self.setPinsOnMapView(results)
                }
            })
        }
        
        self.backwardHandler = {
            let targetDateTime = self.currentDate.addingTimeInterval(-1*24*60*60)
            self.setTitleToNavigationView(with: targetDateTime)
            let fromDate:Date = AWAREUtils.getTargetNSDate(targetDateTime, hour: 0, nextDay: false)
            let toDate:Date   = AWAREUtils.getTargetNSDate(targetDateTime, hour: 0, nextDay: true)
            if let storage = locationSensor.storage {
                storage.fetchData(from: fromDate, to: toDate) { (name, results, from, to, error) in
                    DispatchQueue.main.sync {
                        self.setPinsOnMapView(results)
                    }
                }
            }
        }
        
        self.forwardHandler = {
            let targetDateTime = self.currentDate.addingTimeInterval(24*60*60)
            self.setTitleToNavigationView(with: targetDateTime)
            let fromDate:Date = AWAREUtils.getTargetNSDate(targetDateTime, hour: 0, nextDay: false)
            let toDate:Date   = AWAREUtils.getTargetNSDate(targetDateTime, hour: 0, nextDay: true)
            if let storage = locationSensor.storage {
                storage.fetchData(from: fromDate, to: toDate) { (name, results, from, to, error) in
                    DispatchQueue.main.sync {
                        self.setPinsOnMapView(results)
                    }
                }
            }

        }
    }
    
    func setPinsOnMapView(_ results:Array<Any>?){
        
        if let mv = self.mapView{
        
            mv.removeAnnotations(mv.annotations)
            if let polyline = self.polyline {
                mv.removeOverlay(polyline)
            }
                
            
            self.indicatorView.isHidden = true
            mv.isHidden = false
            
            var mapPoints:[CLLocationCoordinate2D] = Array()
            self.lastLocation = nil
            var weight:Float = 0.1;
            var pins:[MyPointAnnotation] = Array<MyPointAnnotation>()
            
            for result in results as! Array<Dictionary<String, Any>> {
                // double_latitude
                // double_longitude
                let latitude = result["double_latitude"] as! Double?
                let longitude = result["double_longitude"] as! Double?
                // show artwork on map
                let loc = CLLocationCoordinate2DMake(latitude!, longitude!)
                
                // filter location data
                if let lastLoc = self.lastLocation {
                    let a = CLLocation(latitude: lastLoc.latitude, longitude: lastLoc.longitude)
                    let b = CLLocation(latitude: loc.latitude, longitude: loc.longitude)
                    if a.distance(from: b) > 50 { // 50m
                        
                        if let lastPin = pins.last {
                            lastPin.pinTintColor = UIColor(red: 1, green: 0, blue: 0, alpha: CGFloat(weight))
                        }
                        // add an annotatiion
                        let item = MyPointAnnotation()
                        item.coordinate = loc
                        pins.append(item)
                        
                        mapPoints.append(loc)

                        // save the current location as the last location
                        self.lastLocation = loc

                        weight = 0.1
                    }else{
                        weight += 0.05
                        if weight > 1 {
                            weight = 1
                        }
                    }
                }else{
                    // add an annotatiion
                    let item = MyPointAnnotation()
                    item.coordinate = loc
                    pins.append(item)
                    // line
                     mapPoints.append(loc)
                    // save the current location as the last location
                    self.lastLocation = loc
                }
            }

            mv.addAnnotations(pins)
            mv.showAnnotations(mv.annotations, animated: true)
            
            // remove a previous polyline
            if let polyline = self.polyline {
                self.mapView?.removeOverlay(polyline)
            }
            
            // create a polyline with all cooridnates
            self.polyline = MyPolyline(coordinates:mapPoints, count: mapPoints.count)
            // set the created polyline
            if let polyline = self.polyline {
                self.mapView?.addOverlay(polyline)
            }
        }
    }
    
}

extension MapCard: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        self.render = MKPolylineRenderer(overlay: overlay)
        self.render?.lineWidth   = 5
        self.render?.lineJoin    = .round
        self.render?.lineCap     = .round
        
        if let myPolyline = overlay as? MyPolyline  {
            if let color = myPolyline.strokeColor{
                self.render?.strokeColor = color.withAlphaComponent(0.8)
            }else{
                self.render?.strokeColor = UIColor.gray.withAlphaComponent(0.5)
            }
        }
        return self.render!
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "myAnnotation") as? MKPinAnnotationView

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myAnnotation")
        } else {
            annotationView?.annotation = annotation
        }

        if let annotation = annotation as? MyPointAnnotation {
            annotationView?.pinTintColor = annotation.pinTintColor
        }

        return annotationView
    }
}

class MyPointAnnotation : MKPointAnnotation {
    var pinTintColor: UIColor?
}

class MyPolyline: MKPolyline {
    var strokeColor: UIColor?
}


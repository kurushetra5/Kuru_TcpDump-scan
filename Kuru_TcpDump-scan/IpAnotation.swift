//
//  IpAnotation.swift
//  Kuru_TcpDump-scan
//
//  Created by Kurushetra on 30/8/17.
//  Copyright © 2017 Kurushetra. All rights reserved.
//

import Cocoa
import MapKit




class IpAnotation:NSObject, MKAnnotation {

    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var node:Node!
    
    
    
    override init() {
        coordinate = CLLocationCoordinate2D()
        coordinate.latitude = 43.545
        coordinate.longitude  = 2.544
        title = "Error: NO SET"
        subtitle = "No Filled"
        super.init()
    }
   
    
    
  static  func ipAnotationFor(map:MKMapView, annotation:MKAnnotation) -> MKAnnotationView {
    
    var anotationView: MKPinAnnotationView?
    
    if let dequeAnotation  = map.dequeueReusableAnnotationView(withIdentifier:IpAnotation.className()) {
        anotationView = dequeAnotation as? MKPinAnnotationView
    }else {
        anotationView = MKPinAnnotationView(annotation:annotation, reuseIdentifier:IpAnotation.className())
        anotationView?.pinTintColor = .blue
 
        
    }
    return anotationView!
    }
    
}

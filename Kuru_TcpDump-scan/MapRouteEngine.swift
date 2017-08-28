//
//  MapRouteEngine.swift
//  Kuru_TcpDump-scan
//
//  Created by Kurushetra on 26/8/17.
//  Copyright © 2017 Kurushetra. All rights reserved.
//

import Foundation
import MapKit
import CloudKit









//FIXME: comprobar si hay delegados antes de enviar la llamada....


class MapRouteEngine: NSObject ,MKMapViewDelegate  {
    
    
    
    
    //MARK: ---------------- Map  ---------------- Vars
    var mapView:MKMapView!
    
    
    
    
    //MARK: ---------------- Location ---------------- Vars
   
     var currentLocation:CLLocation!
    
    
    
    
    //MARK: ---------------- INIT  -------------------------- INIT
    
    init(withMap:MKMapView ) {
        super.init()
        configureMap(withMap)
        
        
    }
    
    
    deinit { //FIXME: cuando se ejecuta...
        print("Deinit de MapRouteEngine")
             }
    
    
    
    
    
    func configureMap(_ map:MKMapView) {
        
        mapView = map
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.showsScale = true
         mapView.mapType = .standard
        mapView.showsCompass = true
        
    }
    
    
    
    
    //MARK: ---------------- Start   ------------------  Func
    
    
    func startEngine() {
        
       
        
    }
    
    
    
    
    
    func  focusAllRouteInView() {
        
        let visibleRegion = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate,1200,1200)
        self.mapView.setRegion(self.mapView.regionThatFits(visibleRegion), animated: true)
        
    }
    
    

    //MARK: ---------------- Map Drawing ------------------  Func
    
    
    
    
    func drawCrossedLine(fromPoint:CLLocation,toPoint:CLLocation) {
        
        
        
        let line:MKPolyline = MKPolyline(coordinates:[fromPoint.coordinate,toPoint.coordinate] , count:2)
        self.mapView.add(line, level: MKOverlayLevel.aboveRoads)
        
    }
    
    
    
    
    func drawHaLine(locationA:CLLocation,locationB:CLLocation) {
        
        let line:MKPolyline = MKPolyline(coordinates:[locationA.coordinate,locationB.coordinate] , count:2)
        self.mapView.add(line, level: MKOverlayLevel.aboveRoads)
        
        
    }
    
    
    
    
    
    func drawVisitedLine( fromPoint:CLLocation,toPoint:CLLocation) {
        
        
       
        
        
        let sourceLocation = fromPoint.coordinate
        let destinationLocation = toPoint.coordinate
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .walking
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            
            let route = response.routes[0]
            self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
        }
        
        
    }
    
    
    
    
    
    
    
    
    func drawLine(fromPoint:CLLocation,toPoint:CLLocation) {
        
       
        
        let sourceLocation = fromPoint.coordinate
        let destinationLocation = toPoint.coordinate
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .walking
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            
            let route = response.routes[0]
            self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            //            let mapRect:MKMapRect = MKMapRect(origin:MKMapPoint.init(x:100, y: 200), size:MKMapSize.init(width:100, height: 100))
            
            //FIXME: Aqui se debe de poner el mapa centrado en su posicion y la ruta. o centrarlo manual
            
            
            //            let rect = route.polyline.boundingMapRect
            //            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
            
            
        }
        
        
    }
    
    
    
    
    
    
    
    
    
    
    //MARK: ---------------- Map View ------------------  Delegates
    
    
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "customCallout")
        
        if annotationView == nil {
//            annotationView = PersonWishListAnnotationView(annotation: annotation, reuseIdentifier: "customCallout")
//            (annotationView as! PersonWishListAnnotationView).personDetailDelegate = self
            
        } else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
        
        
        
    }
    
    
    
    
     func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        
        //        let visibleRegion = MKCoordinateRegionMakeWithDistance( (view.annotation?.coordinate)!, 500, 500)
        //        self.mapView.setRegion(self.mapView.regionThatFits(visibleRegion), animated: true)
        
        self.mapView.setCenter((view.annotation?.coordinate)! , animated: true)
        
        
        
        //          let locationToGo = self.mapView.convert(CGPoint.init(x:self.mapView.center.x, y:400), toCoordinateFrom:view)
        //
        //
        //
        //         self.mapView.setCenter(locationToGo, animated: true)
        
    }
    
    
    
    
//    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        
//        //        let an:KUAnotation = (view as KUAnotation)!
//        
//        //        routesManager.audioForAnotation(anotation:KUAnotation())
//    }
    
    
    
    
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        
             renderer.strokeColor = .green
            renderer.lineWidth = 3.5
            renderer.lineDashPattern = [3,5]
            renderer.alpha = 1.0
            
            
                return renderer
    }
    
    
    
    
    
    
}



//
//  Node+CoreDataClass.swift
//  AppController-scan
//
//  Created by Kurushetra on 1/9/17.
//  Copyright © 2017 Kurushetra. All rights reserved.
//

import Foundation
import CoreData

@objc(Node)
public class Node: NSManagedObject {

    var anotation:IpAnotation!
    
    
    
    
    func isFilled() -> Bool {
        if number != nil && city != nil && country != nil && aso != nil { //FIXME: poner mas
            return true
        }
        return false
    }
    
    
    
    func isEqualTo(node:Node) -> Bool {
        
        if self.latitud == node.latitud && self.longitude == node.longitude {
            return true
        }else {
            return false
        }
    }

    
    func nodeAnotation() -> IpAnotation {
        
        let nodeAnotation:IpAnotation = IpAnotation()
        nodeAnotation.title = self.aso
        nodeAnotation.subtitle = self.number
        nodeAnotation.coordinate.latitude = self.latitud
        nodeAnotation.coordinate.longitude = self.longitude
        nodeAnotation.node = self

        return nodeAnotation
    }
    
    
    func fillFrom(ipLocation:IPLocation) -> Node {
        self.number =  ipLocation.query
        self.aso =  ipLocation.as
        self.city =  ipLocation.city
        self.country =  ipLocation.country
        self.latitud =  ipLocation.lat
        self.longitude =  ipLocation.lon
        
        //         timesBlocked: Int64
        //         timesSeeIt: Int64
        //         conectionPorts: NSSet?
        return self //FIXME: no se si esto esta bien o solo rellenarlo
    }
    
    
//    func fromNode(node:TraceRouteNode) -> Node {
//        self.number =  node.ip
//        self.aso =  node.aso
//        self.city =  node.city
//        self.country =  node.country
//        self.latitud =  node.lat
//        self.longitude =  node.lon
//
//        //         timesBlocked: Int64
//        //         timesSeeIt: Int64
//        //         conectionPorts: NSSet?
//        return self
//    }

}

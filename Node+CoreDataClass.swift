//
//  Node+CoreDataClass.swift
//  Kuru_TcpDump-scan
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
        if number != nil && city != nil && country != nil && aso != nil && longitude != nil  {
            return true
        }
        return false
    }
    
    
    func fromNode(node:TraceRouteNode) -> Node {
        self.number =  node.ip
        self.aso =  node.aso
        self.city =  node.city
        self.country =  node.country
        self.latitud =  node.lat
        self.longitude =  node.lon
    
        //         timesBlocked: Int64
        //         timesSeeIt: Int64
        //         conectionPorts: NSSet?
        return self
    }

}

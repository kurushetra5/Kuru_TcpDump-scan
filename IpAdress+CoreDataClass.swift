//
//  IpAdress+CoreDataClass.swift
//  Kuru_TcpDump-scan
//
//  Created by Kurushetra on 24/8/17.
//  Copyright © 2017 Kurushetra. All rights reserved.
//

import Foundation
import CoreData

@objc(IpAdress)
public class IpAdress: NSManagedObject {

    var anotation:IpAnotation!
    
    
    func isFilled() -> Bool {
        if number != nil && city != nil && country != nil && aso != nil && longitude != nil  {
           return true
        }
        return false
    }
    
    
    func fromNode(node:TraceRouteNode) -> IpAdress {
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

//
//  TraceRouteNode.swift
//  Kuru_TcpDump-scan
//
//  Created by Kurushetra on 28/8/17.
//  Copyright © 2017 Kurushetra. All rights reserved.
//

import Foundation

class  TraceRouteNode  {
    
    var ip:String!
    var ips:String!
    var number:String!
    
    
    var aso:String!
    var city:String!
    var country:String!
    var countryCode:String!
    var isp:String!
    var lat:Double!
    var lon:Double!
    var org:String!
    var region:String!
    var regionName:String!
    var status:String!
    var timezone:String!
    var zip:String!
    
    
    func isEqualTo(node:TraceRouteNode) -> Bool {
        
        if self.lat == node.lat && self.lon == node.lon {
            return true
        }else {
            return false
        }
    }
    
    
//    init(aso:String) {
//        self.aso = aso
//        
//    }
    
}

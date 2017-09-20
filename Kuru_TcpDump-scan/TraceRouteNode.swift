//
//  TraceRouteNode.swift
//  Kuru_TcpDump-scan
//
//  Created by Kurushetra on 28/8/17.
//  Copyright © 2017 Kurushetra. All rights reserved.
//

import Foundation

protocol NodeFilledDelegate {
    func filled(node:TraceRouteNode)
}



class  TraceRouteNode:IPLocatorDelegate  {
    
    let dataBase:dataBaseManager = dataBaseManager()
    var ipLocator:IPLocator = IPLocator()
    var nodeFilledDelegate:NodeFilledDelegate!
    
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
    var isFilledOk:Bool = false
    
    
    
    
    init(ip:String) {
        self.ip  = ip
        isFilledOk = false
        nodeFilledDelegate = nil
        ipLocator.locatorDelegate = self
    }

    
    
    func isEqualTo(node:TraceRouteNode) -> Bool {
        
        if self.lat == node.lat && self.lon == node.lon {
            return true
        }else {
            return false
        }
    }
    
    
    
    func fillNodeWithData() {
        
        if dataBase.isFilledThis(node:self) {
            print("Node is Founded in DataBase")
            fillWithCoreDataNode(node:dataBase.foundedNode)
        } else {
            print("Node is Filling from Internet")
            ipLocator.fetchIpLocation(node:self)
        }
    }
    
    
    
    
    func fillWithCoreDataNode(node:Node) {
        
        self.aso  = node.aso
        self.city = node.city
        self.country = node.country
        self.countryCode = node.countryCode
//        self.isp = node.isp
        self.lat = node.latitud
        self.lon = node.longitude
        self.org = node.org
        self.region = node.region
        self.regionName = node.regionName
        self.status = node.status
//        self.timezone = node.timezone
        self.zip = node.zip
        isFilledOk = true
        nodeFilledDelegate?.filled(node:self)
    }
    
    
    
    func nodeIpReady(node:TraceRouteNode) {
        
        self.aso  = node.aso
        self.city = node.city
        self.country = node.country
        self.countryCode = node.countryCode
        self.isp = node.isp
        self.lat = node.lat
        self.lon = node.lon
        self.org = node.org
        self.region = node.region
        self.regionName = node.regionName
        self.status = node.status
        self.timezone = node.timezone
        self.zip = node.zip
        isFilledOk = true
        
        nodeFilledDelegate?.filled(node:self)
    }
    
    
    
}

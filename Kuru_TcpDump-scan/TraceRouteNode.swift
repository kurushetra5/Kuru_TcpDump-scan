//
//  TraceRouteNode.swift
//  AppController-scan
//
//  Created by Kurushetra on 28/8/17.
//  Copyright © 2017 Kurushetra. All rights reserved.
//

import Foundation

//protocol NodeFilledDelegate {
//    func filled(node:TraceRouteNode)
//    func filled(node:TraceRouteNode, amountIps:Int)
//}



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
    var amountIpsToCheck:Int!
    var withAmountTarget:Bool = false
    
    
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
    
    
    func fillNodeWithData(amountIps:Int) {
        withAmountTarget = true
        amountIpsToCheck = amountIps
        fillNode()
    }
    
    func fillNodeWithData() {
        withAmountTarget = false
        fillNode()
    }
    
    
    
    func fillNode() {
        
//        if dataBase.isFilledThis(node:self) {
//            print("Node is Founded in DataBase")
//            fillWithCoreDataNode(node:dataBase.foundedNode)
//        } else {
//            print("Node is Filling from Internet")
////            ipLocator.fetchIpLocation(node:self)
//        }
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
        
        callDelegates()
        
        
    }
    
    func ipLocationReady(ipLocation:IPLocation) {
        
    }
    func nodeIpReady(node: Node) {
        
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
        
        callDelegates()
        
    }
    
    
    
    func callDelegates() {
        
//        if withAmountTarget == true {
//            nodeFilledDelegate?.filled(node:self, amountIps:amountIpsToCheck)
//        }else {
//            nodeFilledDelegate?.filled(node:self)
//        }
    }
    
}

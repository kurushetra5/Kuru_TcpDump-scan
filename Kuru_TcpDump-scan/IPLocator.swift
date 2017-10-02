//
//  IPLocator.swift
//  AppController-scan
//
//  Created by Kurushetra on 28/8/17.
//  Copyright © 2017 Kurushetra. All rights reserved.
//


import Foundation

protocol IPLocatorDelegate {
//    func nodeIpReady(node:TraceRouteNode)
    func nodeIpReady(node:Node)
    func ipLocationReady(ipLocation:IPLocation)
}

struct  IPLocation:Codable {
    var query:String
    var isp:String
    var `as`:String
    var city:String
    var country:String
    var countryCode:String
    var lat:Double
    var lon:Double
    var org:String
    var region:String
    var regionName:String
    var status:String
    var timezone:String
    var zip:String
}



class   IPLocator  {
    
    
    
    
    
    //    {"as":"AS9394 China TieTong Telecommunications Corporation","city":"Beijing","country":"China","countryCode":"CN","isp":"China TieTong","lat":39.9289,"lon":116.3883,"org":"China TieTong","query":"61.232.254.39","region":"11","regionName":"Beijing","status":"success","timezone":"Asia/Shanghai","zip":""}
    var locatorDelegate:IPLocatorDelegate!
    
    
    
    func fetchIpLocation(ip:String) {
        
        
        let decoder = JSONDecoder()
        
        let url = URL(string:"http://ip-api.com/json/" + ip)
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print(error ?? "Error in fetchIpLocation")
                //TODO: delegate message error
            }else{
                do{
                    let node = try decoder.decode(IPLocation.self, from: data!)
//                    print(node)
                    OperationQueue.main.addOperation({
                        self.locatorDelegate.ipLocationReady(ipLocation:node)
                        
                   })
                    
                }catch let error as NSError{ //FIXME: pasar un node con la info rellena co el de error.
                    print(error)
                     print(ip)
                    
                }
            }
        }).resume()
    }
    
    
    
    
//    func fetchIpLocation(node:TraceRouteNode) {
//
//        let nodeString:String = node.ip
//       let decoder = JSONDecoder()
//
//        let url = URL(string:"http://ip-api.com/json/" + nodeString)
//        URLSession.shared.dataTask(with: url!, completionHandler: {
//            (data, response, error) in
//            if(error != nil){
//                print(error ?? "Error in fetchIpLocation")
//                //TODO: delegate message error
//            }else{
//                do{
//
//                let todo = try decoder.decode(IPLocation.self, from: data!)
//                    print(todo)
//
//
//
//                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
//                    OperationQueue.main.addOperation({
//                        node.aso  = json["as"] as? String
//                        node.city = json["city"] as? String
//                        node.country = json["country"] as? String
//                        node.countryCode = json["countryCode"] as? String
//                        node.isp = json["isp"] as? String
//                        node.lat = json["lat"] as? Double
//                        node.lon = json["lon"] as? Double
//                        node.org = json["org"] as? String
//                        node.region = json["region"] as? String
//                        node.regionName = json["regionName"] as? String
//                        node.status = json["status"] as? String
//                        node.timezone = json["timezone"] as? String
//                        node.zip = json["zip"] as? String
//
//                        if node.lat != nil && node.lon != nil {
////                           self.locatorDelegate.nodeIpReady(node:node)
//                        }
//                   })
//
//                }catch let error as NSError{
//                    print(error)
//                }
//            }
//        }).resume()
//    }
    
    
}

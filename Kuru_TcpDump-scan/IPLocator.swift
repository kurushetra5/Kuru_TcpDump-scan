//
//  IPLocator.swift
//  Kuru_TcpDump-scan
//
//  Created by Kurushetra on 28/8/17.
//  Copyright © 2017 Kurushetra. All rights reserved.
//


import Foundation

protocol IPLocatorDelegate {
    func nodeIpReady(node:TraceRouteNode)
}


class   IPLocator  {
    
    //    {"as":"AS9394 China TieTong Telecommunications Corporation","city":"Beijing","country":"China","countryCode":"CN","isp":"China TieTong","lat":39.9289,"lon":116.3883,"org":"China TieTong","query":"61.232.254.39","region":"11","regionName":"Beijing","status":"success","timezone":"Asia/Shanghai","zip":""}
    var locatorDelegate:IPLocatorDelegate!
    
    func fetchIpLocation(node:TraceRouteNode) {
        
        
        let nodeString:String = node.ip
        
        let url = URL(string:"http://ip-api.com/json/" + nodeString)
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print(error ?? "Error in fetchIpLocation")
            }else{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                    
                    //                    let lon:String = String(describing: json["longitude"] as! NSNumber)
                    //                    print(lon)
                    
                    OperationQueue.main.addOperation({
                        
                        node.aso  = json["as"] as? String
                        node.city = json["city"] as? String
                        node.country = json["country"] as? String
                        node.countryCode = json["countryCode"] as? String
                        node.isp = json["isp"] as? String
                        node.lat = json["lat"] as? Double
                        node.lon = json["lon"] as? Double
                        node.org = json["org"] as? String
                        node.region = json["region"] as? String
                        node.regionName = json["regionName"] as? String
                        node.status = json["status"] as? String
                        node.timezone = json["timezone"] as? String
                        node.zip = json["zip"] as? String
                        
                        if node.lat != nil && node.lon != nil {
                           self.locatorDelegate.nodeIpReady(node:node)
                        }
                        
//                       print(node.lat ?? 0.0)
//                        print(node.lon ?? 0.0)
                        
                    })
                    
                }catch let error as NSError{
                    print(error)
                }
            }
        }).resume()
        
    }
    
    
}

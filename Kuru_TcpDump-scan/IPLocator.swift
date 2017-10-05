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
    
    
   
    
}

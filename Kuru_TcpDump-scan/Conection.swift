//
//  Conection.swift
//  Kuru_TcpDump-scan
//
//  Created by Kurushetra on 24/8/17.
//  Copyright © 2017 Kurushetra. All rights reserved.
//

import Foundation



struct  Conection  {
    
    var comIp:String!
    var comIpLongitude:String!
    var comIpLatitud:String!
    var goIp:String!
    var goIpLongitude:String!
    var goIpLatitud:String!
    var conectionTime:Double!
    
    
    init() {
        //
    }
    
    
    func isFilled() -> Bool {
        
        if comIp != nil && goIp != nil && comIpLongitude != nil && comIpLatitud != nil && goIpLongitude != nil && goIpLatitud != nil && conectionTime != nil {
            return true
        } else {
           return false
        }
    }
    
}


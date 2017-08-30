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
        if number != nil && city != nil && country != nil && adress != nil && longitude != nil  {
           return true
        }
        return false
    }
    
}

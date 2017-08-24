//
//  PortConection+CoreDataProperties.swift
//  Kuru_TcpDump-scan
//
//  Created by Kurushetra on 24/8/17.
//  Copyright © 2017 Kurushetra. All rights reserved.
//

import Foundation
import CoreData


extension PortConection {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PortConection> {
        return NSFetchRequest<PortConection>(entityName: "PortConection")
    }

    @NSManaged public var dateConection: NSDate?
    @NSManaged public var port: String?
    @NSManaged public var ipAdress: IpAdress?

}

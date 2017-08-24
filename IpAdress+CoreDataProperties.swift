//
//  IpAdress+CoreDataProperties.swift
//  Kuru_TcpDump-scan
//
//  Created by Kurushetra on 24/8/17.
//  Copyright © 2017 Kurushetra. All rights reserved.
//

import Foundation
import CoreData


extension IpAdress {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<IpAdress> {
        return NSFetchRequest<IpAdress>(entityName: "IpAdress")
    }

    @NSManaged public var adress: String?
    @NSManaged public var city: String?
    @NSManaged public var country: String?
    @NSManaged public var latitud: Double
    @NSManaged public var longitude: String?
    @NSManaged public var number: String?
    @NSManaged public var timesBlocked: Int64
    @NSManaged public var timesSeeIt: Int64
    @NSManaged public var conectionPorts: NSSet?

}

// MARK: Generated accessors for conectionPorts
extension IpAdress {

    @objc(addConectionPortsObject:)
    @NSManaged public func addToConectionPorts(_ value: PortConection)

    @objc(removeConectionPortsObject:)
    @NSManaged public func removeFromConectionPorts(_ value: PortConection)

    @objc(addConectionPorts:)
    @NSManaged public func addToConectionPorts(_ values: NSSet)

    @objc(removeConectionPorts:)
    @NSManaged public func removeFromConectionPorts(_ values: NSSet)

}

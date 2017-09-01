//
//  IpAdress+CoreDataProperties.swift
//  Kuru_TcpDump-scan
//
//  Created by Kurushetra on 1/9/17.
//  Copyright © 2017 Kurushetra. All rights reserved.
//

import Foundation
import CoreData


extension IpAdress {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<IpAdress> {
        return NSFetchRequest<IpAdress>(entityName: "Node")
    }

    @NSManaged public var aso: String?
    @NSManaged public var city: String?
    @NSManaged public var country: String?
    @NSManaged public var latitud: Double
    @NSManaged public var longitude: Double
    @NSManaged public var number: String?
    @NSManaged public var timesBlocked: Int64
    @NSManaged public var timesSeeIt: Int64
    @NSManaged public var countryCode: String?
    @NSManaged public var ips: String?
    @NSManaged public var org: String?
    @NSManaged public var region: String?
    @NSManaged public var regionName: String?
    @NSManaged public var status: String?
    @NSManaged public var timeZone: String?
    @NSManaged public var zip: String?
    @NSManaged public var conectionPorts: NSSet?

}

// MARK: Generated accessors for conectionPorts
extension IpAdress {

    @objc(addConectionPortsObject:)
    @NSManaged public func addToConectionPorts(_ value: NSManagedObject)

    @objc(removeConectionPortsObject:)
    @NSManaged public func removeFromConectionPorts(_ value: NSManagedObject)

    @objc(addConectionPorts:)
    @NSManaged public func addToConectionPorts(_ values: NSSet)

    @objc(removeConectionPorts:)
    @NSManaged public func removeFromConectionPorts(_ values: NSSet)

}

//
//  Node+CoreDataProperties.swift
//  AppController-scan
//
//  Created by Kurushetra on 1/9/17.
//  Copyright © 2017 Kurushetra. All rights reserved.
//

import Foundation
import CoreData


extension Node {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Node> {
        return NSFetchRequest<Node>(entityName: "Node")
    }

    @NSManaged public var aso: String?
    @NSManaged public var city: String?
    @NSManaged public var country: String?
    @NSManaged public var latitud: Double
    @NSManaged public var longitude: Double
    @NSManaged public var number: String?
    @NSManaged public var blocked: Bool
    @NSManaged public var timesSeeIt: Int16
    @NSManaged public var countryCode: String?
    @NSManaged public var ips: String?
    @NSManaged public var org: String?
    @NSManaged public var region: String?
    @NSManaged public var regionName: String?
    @NSManaged public var status: String?
    @NSManaged public var timeZone: String?
    @NSManaged public var zip: String?

}

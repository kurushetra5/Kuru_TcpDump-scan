//
//  dataBaseManager.swift
//  Kuru_TcpDump-scan
//
//  Created by Kurushetra on 31/8/17.
//  Copyright © 2017 Kurushetra. All rights reserved.
//

import Foundation
import CoreData
import Cocoa





class dataBaseManager {

    let appDelegate = NSApplication.shared.delegate  as! AppDelegate
    let managedContext:NSManagedObjectContext!
    var foundedNode:Node!
    
    
    init() {
        managedContext = self.appDelegate.persistentContainer.viewContext
    }
    
    
    func  newIpEntity() -> Node {
        let entity = NSEntityDescription.entity(forEntityName: "Node", in: self.managedContext)!
        let ip = NSManagedObject(entity: entity,insertInto: self.managedContext) as! Node
        return ip
    }

   
    
    
    
    
    
    
    
    
    func newIpWith(node:TraceRouteNode) -> Node {
        
        
        var newIp:Node = newIpEntity()
        newIp = newIp.fromNode(node: node)
        
        
//        if dataBaseMode == DataBaseMode.on {
        
//            ipsFound.append(newIp)
//            self.tcpDumpDelegate?.newIpComing(ips:self.ipsFound)
        
            do {
                try self.managedContext.save()
                
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
//        }else {
//            ipsFoundOffMode.append(newIp)
//            self.tcpDumpDelegate?.newIpComing(ips:self.ipsFoundOffMode)
//        }
        return newIp
    }

    
    
    
    func isFilledThis(node:TraceRouteNode) -> Bool {
        
        if fetchInfoFor(node:node).found == true {
//            let ipNode:String = node.ip
//            print(ipNode)
             return true
        }else {
             return false
        }
        
        //TODO: mirar si esta si esta rellenar si no false y lo localiza
       
    }
    
    
    
    func fetchInfoFor(node:TraceRouteNode) -> (found:Bool,ip:Node) { //FIXME: Sobra ip

        var founded:Bool = false
        var foundNode:Node = Node()
        
        let fetchRequest: NSFetchRequest<Node> = Node.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "number == %@",node.ip)
        
        do {
            let searchResults = try managedContext.fetch(fetchRequest)
            print ("num of results = \(searchResults.count)")
            
            if searchResults.count >= 2 {
                print("Duplicate Ip found")
                founded = true
                foundNode = searchResults[0]//FIXME: Sobra
                foundedNode = searchResults[0]
            }
            if searchResults.count == 1 {
                founded = true
                foundNode = searchResults[0]//FIXME: Sobra
                foundedNode = searchResults[0]
            }
        
        } catch {
            print("Error with request: \(error)")
        }
        return (founded,foundNode)
    }
 
        
    
    
    
    
    
    
    func fetchInfoFor(node:TraceRouteNode) -> Bool {
      print(node.ip)
        var founded:Bool = false
        
        let fetchRequest: NSFetchRequest<Node> = Node.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "number == %@",node.ip)
   
               do {
                   let searchResults = try managedContext.fetch(fetchRequest)
                   print ("num of results = \(searchResults.count)")
                if searchResults.count >= 2 {
                    print("Duplicate Ip found")
                    founded = true
                }
                if searchResults.count == 1 {
                    founded = true
                    foundedNode = searchResults[0]
//                    var newNode:Node = newIpEntity()
//                    newNode.aso =
                    
//                    let ipResult:Node = searchResults[0]
//                    node.lat = ipResult.latitud
//                    node.lon =  ipResult.longitude
//                    node.aso = ipResult.aso
//                    node.city = ipResult.city
                }
                
    //                for ip in searchResults as [Node] {
    //                    newConection.comIpLatitud = String(ip.value(forKey: "latitud") as! Double )
    //                    newConection.comIpLongitude = ip.value(forKey: "longitude") as! String
    //                }
                } catch {
                     print("Error with request: \(error)")
                }
        return founded
        
//            }
    //
    //        if direction == Direction.going {
    //
    //            let fetchRequest: NSFetchRequest<Node> = Node.fetchRequest()
    //            fetchRequest.predicate = NSPredicate(format: "number == %@", conection.goIp)
    //
    //            do {
    //                let searchResults = try managedContext.fetch(fetchRequest)
    //                print ("num of results = \(searchResults.count)")
    //
    //                for ip in searchResults as [Node] {
    //                    newConection.goIpLatitud = String(ip.value(forKey: "latitud") as! Double )
    //                    newConection.goIpLongitude = ip.value(forKey: "longitude") as! String
    //
    //
    //                    //                    print("\(String(describing: ip.value(forKey: "number")))")
    //                }
    //            } catch {
    //                print("Error with request: \(error)")
    //            }
    //        }
    //
    //
    //        if self.newConection.isFilled() {
    ////            self.newConectionReadyToShow()
    //        }
    //
      }
   

    
    //    func fetchCoreDataInfoForNew(conection:Conection , direction:Direction) {
    //
    //        if direction == Direction.coming {
    //
    //            let fetchRequest: NSFetchRequest<Node> = Node.fetchRequest()
    //            fetchRequest.predicate = NSPredicate(format: "number == %@",conection.comIp)
    //
    //            do {
    //                let searchResults = try managedContext.fetch(fetchRequest)
    //                print ("num of results = \(searchResults.count)")
    //
    //                for ip in searchResults as [Node] {
    //                    newConection.comIpLatitud = String(ip.value(forKey: "latitud") as! Double )
    //                    newConection.comIpLongitude = ip.value(forKey: "longitude") as! String
    //                }
    //            } catch {
    //                print("Error with request: \(error)")
    //            }
    //        }
    //
    //        if direction == Direction.going {
    //
    //            let fetchRequest: NSFetchRequest<Node> = Node.fetchRequest()
    //            fetchRequest.predicate = NSPredicate(format: "number == %@", conection.goIp)
    //
    //            do {
    //                let searchResults = try managedContext.fetch(fetchRequest)
    //                print ("num of results = \(searchResults.count)")
    //
    //                for ip in searchResults as [Node] {
    //                    newConection.goIpLatitud = String(ip.value(forKey: "latitud") as! Double )
    //                    newConection.goIpLongitude = ip.value(forKey: "longitude") as! String
    //
    //
    //                    //                    print("\(String(describing: ip.value(forKey: "number")))")
    //                }
    //            } catch {
    //                print("Error with request: \(error)")
    //            }
    //        }
    //        
    //        
    //        if self.newConection.isFilled() {
    ////            self.newConectionReadyToShow()
    //        }
    //        
    //    }
    //    

    
}

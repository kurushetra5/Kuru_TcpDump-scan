//
//  KuTcp_Scaner.swift
//  AppController-scan
//
//  Created by Kurushetra on 20/8/17.
//  Copyright © 2017 Kurushetra. All rights reserved.
//

import Foundation
import Cocoa


protocol  IPsDelegate {
    func newIpComing(ips:[Node])
    func newConection(ip:Node)
    func newNode(node:Node)
    func newPackage()
    func packageProcessed(number:Int)
    func showAnotationsInMap(anotations:[IpAnotation])
}


enum  NotesInMapMode:Int {
    case on,off
}





class AppController    {
    
    enum  Direction:Int {
        case coming,going
    }
    enum  DataBaseMode:Int {
        case on,off
    }
    
    
    var tcpDumpComand:TcpDump = TcpDump()
    
    
    
    
    
    //MARK: ---------------- VARS -------------------------
    
    let appDelegate = NSApplication.shared.delegate  as! AppDelegate
    let managedContext:NSManagedObjectContext!
    var ipsDelegate:IPsDelegate?
    var comandsManager:Comands = Comands.shared
    var ipLocator:IPLocator = IPLocator()
    let dataBase:dataBaseManager = dataBaseManager()
    
    var newConection:Conection = Conection()
    var filterInTcpDumpCommand:FilterInTcpDumpCommand = FilterInTcpDumpCommand.off
    var showNodesInMapView:NotesInMapMode = NotesInMapMode.off
    
    
   
    
    func nodeIpReady(node: Node) {
        
    }
 
    func ipLocationReady(ipLocation:IPLocation) {
        
    }
    
    
    //MARK: ---------------- INIT -------------------------
      init() {
        managedContext = self.appDelegate.persistentContainer.viewContext
//        comandsManager.traceRouteIpsDelegate = self
//        ipLocator.locatorDelegate = self
//        tcpDumpComand.tcpDumpDelegate  = self
    }
    
    
    func dataBaseModeOff() {
        tcpDumpComand.dataBaseModeOff()
    }
    
    
    func countPackages(mode:Int) {
        tcpDumpComand.countPackagesMode = PackagesMode(rawValue:mode)!
    }
    
    func countProcessed(mode:Int) {
        tcpDumpComand.countProcessedMode = ProcessedMode(rawValue:mode)!
    }

    
    
    //MARK: ---------------- START -------------------------
    
    func startTcpScan() {
        tcpDumpComand.startTcpScan()
//        tcpDumpComand.tcpDumpDelegate  = self
    }
    
    func newIpComing(ips:[Node]) {
        
        if showNodesInMapView == NotesInMapMode.on {
            var anotations:[IpAnotation] = []
            for node in ips {
                anotations.append(node.nodeAnotation())
                
            }
            ipsDelegate?.showAnotationsInMap(anotations:anotations)
        }
        ipsDelegate?.newIpComing(ips:ips)
    }
    
    
    
    func newConection(ip:Node) {
        ipsDelegate?.newConection(ip:ip)
    }
 
    func newPackage() {
        ipsDelegate?.newPackage()
    }
    func packageProcessed(number:Int) {
        ipsDelegate?.packageProcessed(number:number)
    }

    func terminateCommand() {
        tcpDumpComand.terminateCommand()
    }
    
    
    //    //MARK: ---------------- TRACE_ROUTE  -------------------------
    func traceRouteTo(ip:String) {
//        comandsManager.traceRouteTo(ip:ip)
       
    }

    
    
    //MARK: ---------------- CORE DATA -------------------------
    func cleanDataBase() {
        tcpDumpComand.cleanDataBase()
     }
    
    
    
    //MARK: ---------------- MAP_View Actions -------------------------
    
    func showNodesInMap(mode:NotesInMapMode) {
        showNodesInMapView = NotesInMapMode.on
        tcpDumpComand.getIps()
            
    }
    
    
    
}





 











//
//  Comands.swift
//  Kuru_TcpDump-scan
//
//  Created by Kurushetra on 27/8/17.
//  Copyright © 2017 Kurushetra. All rights reserved.
//

import Foundation

protocol  TraceRouteDelegate {
    func traceRouteIps(ips:[TraceRouteNode])
}

extension DispatchQueue {
    
    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
    
}


class  Comands {
    
    
    let fileExtractor:FileComandExtractor = FileComandExtractor()
    let filesManager:FilesManager = FilesManager.shared
    let tcpDumpTask =  Process()
    var tcpDumpOutFile:FileHandle!
    var tcpDumpFileUrl:URL = URL(fileURLWithPath:"/Users/kurushetra/Desktop/netstat2.txt")
    
    
    var traceRouteIpsDelegate:TraceRouteDelegate!
    let traceRouteTask =  Process()
    var traceRouteOutFile:FileHandle!
    var traceRouteFileUrl:URL = URL(fileURLWithPath:"/Users/kurushetra/Desktop/traceRoute.txt")

    
    
    
    
    
    //MARK: ---------------- TRACE_ROUTE  -------------------------
    func traceRouteTo(ip:String) {
        
        
        DispatchQueue.background(delay: 0.0, background: {
            self.traceRouteTask.launchPath = "/usr/sbin/traceroute"
            self.traceRouteTask.arguments = ["-w 1" , "-m30" ,ip]
            self.traceRouteOutFile = FileHandle(forWritingAtPath:"/Users/kurushetra/Desktop/traceRoute.txt")
            self.traceRouteTask.standardOutput = self.traceRouteOutFile
            
            self.traceRouteTask.launch()
            self.traceRouteTask.waitUntilExit()

        }, completion: {
            print("Completado")
            let ips =  self.extractTraceRouteIps()
            self.traceRouteIpsDelegate?.traceRouteIps(ips:ips)
        })
        
        
        
        
        
        
        
    }
    
    
    func terminateTraceRoute() {
        traceRouteTask.terminate()
    }
    
    
    func extractTraceRouteIps() -> [TraceRouteNode] {
        var ips:[TraceRouteNode] = []
        ips = fileExtractor.extractTraceRoute(fileUrl:traceRouteFileUrl)
        
        return ips
        
    }
    
    
    //MARK: ---------------- TCPDUMP -------------------------
    
    
    func executeTcpDump()   {
        
        tcpDumpTask.launchPath = "/usr/sbin/tcpdump"
        tcpDumpTask.arguments = ["-i","en4","-n"]
        tcpDumpOutFile = FileHandle(forWritingAtPath:"/Users/kurushetra/Desktop/netstat2.txt")
        tcpDumpTask.standardOutput = tcpDumpOutFile
        tcpDumpTask.launch()
        
    }
    
    func terminateCommand() {
        tcpDumpTask.terminate()
    }
    

    
    
    
    
    
    
    
    //MARK: ---------------- WHOIS  -------------------------
    func whoisTo(ip:String) {
        
    }
    
    //MARK: ---------------- NSLOOKUP  -------------------------
    func nsLookupTo(ip:String) {
        
    }
    

    
}

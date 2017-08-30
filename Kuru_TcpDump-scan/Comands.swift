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
protocol  WhoisDelegate {
    func whoisFinish(result:String)
}
protocol LookUpDelegate {
    func lookUpFinish(result:String)
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


final class  Comands {
    
    private init(){}
      static let shared = Comands()
    
    let fileExtractor:FileComandExtractor = FileComandExtractor()
    let filesManager:FilesManager = FilesManager.shared
    
    
    var tcpDumpTask =  Process()
    var tcpDumpOutFile:FileHandle!
    var tcpDumpFileUrl:URL = URL(fileURLWithPath:"/Users/kurushetra/Desktop/netstat2.txt")
    
    
    //MARK: ---------------- TRACE_ROUTE  -------------------------
    var traceRouteIpsDelegate:TraceRouteDelegate!
    let traceRouteTask =  Process()
    var traceRouteOutFile:FileHandle!
    var traceRouteFileUrl:URL = URL(fileURLWithPath:"/Users/kurushetra/Desktop/traceRoute.txt")

     //MARK: ---------------- WHOIS  -------------------------
    var whoisDelegate:WhoisDelegate!
    var whoisTask =  Process()
    var whoisOutFile:FileHandle!
    var whoisFileUrl:URL = URL(fileURLWithPath:"/Users/kurushetra/Desktop/whois.txt")

     //MARK: ---------------- LOOKUP  -------------------------
    var nsLookupDelegate:LookUpDelegate!
    var nsLookupTask =  Process()
    var nsLookupOutFile:FileHandle!
    var nsLookupFileUrl:URL = URL(fileURLWithPath:"/Users/kurushetra/Desktop/nsLookup.txt")
    
    
    
    
    //MARK: ---------------- TRACE_ROUTE  -------------------------
    func traceRouteTo(ip:String) {
        
        
        DispatchQueue.background(delay: 0.0, background: {
            self.traceRouteTask.launchPath = "/usr/sbin/traceroute"
            self.traceRouteTask.arguments = ["-w 1" , "-m30" ,ip]
            self.traceRouteOutFile = FileHandle(forWritingAtPath:"/Users/kurushetra/Desktop/traceRoute.txt")
            self.traceRouteTask.standardOutput = self.traceRouteOutFile
            
            self.traceRouteTask.launch()
            self.traceRouteTask.waitUntilExit() //FIXME: Cambiar ha Observer..

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
        
        tcpDumpTask = Process()
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
    
//    -A      Use the Asia/Pacific Network Information Center (APNIC) database.  It contains network numbers used in East Asia, Australia, New Zealand, and the
//    Pacific islands.
    
//    -a      Use the American Registry for Internet Numbers (ARIN) database.
//    -b      Use the Network Abuse Clearinghouse database.
//    -d      Use the US Department of Defense database.  It contains points of contact for subdomains of .MIL.
//    
//    -g      Use the US non-military federal government database, which contains points of contact for subdomains of .GOV.
//    -c country-code
//    This is the equivalent of using the -h option with an argument of "country-code.whois-servers.net".
//
//     -I      Use the Internet Assigned Numbers Authority (IANA) database.  It contains network information for top-level domains.
    
//    -i      Use the Network Solutions Registry for Internet Numbers (whois.networksolutions.com) database.  It contains network numbers and domain contact infor-
//    mation for most of .COM, .NET, .ORG and .EDU domains.

//    -l      Use the Latin American and Caribbean IP address Regional Registry (LACNIC) database.  It contains network numbers used in much of Latin America and
//    the Caribbean.
//    
//    -m      Use the Route Arbiter Database (RADB) database.  It contains route policy specifications for a large number of operators' networks.
//
//    -Q      Do a quick lookup.  This means that whois will not attempt to lookup the name in the authoritative whois server (if one is listed).  This option has
//    no effect when combined with any other options.
//    
//    -R      Use the Russia Network Information Center (RIPN) database.  It contains network numbers and domain contact information for subdomains of .RU.  This
//    option is deprecated; use the -c option with an argument of "RU" instead.
//    
//    -r      Use the R'eseaux IP Europ'eens (RIPE) database.  It contains network numbers and domain contact information for Europe.
    
    
    func whoisTo(ip:String) {
        
        filesManager.createFileAtPath(path:"/Users/kurushetra/Desktop/whois.txt")
        
        whoisTask = Process()
        whoisTask.launchPath = "/usr/bin/whois"
        whoisTask.arguments = [ip]
        whoisOutFile = FileHandle(forWritingAtPath:"/Users/kurushetra/Desktop/whois.txt")
        whoisTask.standardOutput = whoisOutFile
        NotificationCenter.default.addObserver(self, selector:#selector(whoisFinish), name:Process.didTerminateNotification, object:nil)
        whoisTask.launch()
        
    }
    
    
    @objc func whoisFinish() {
        print("whois finish")
        whoisTask.terminate()
        do   {
           let data = try  Data(contentsOf:whoisFileUrl)
            let dataString:String = String(data:data, encoding:.utf8)!
            whoisDelegate.whoisFinish(result:dataString)
        }catch {
          print("ERROR: whois file not read it..")
        }
        
    }
    
    
    
    
    
    //MARK: ---------------- LOOKUP  -------------------------
    
    func nsLookupTo(ip:String) {
        
        filesManager.createFileAtPath(path:"/Users/kurushetra/Desktop/nsLookup.txt")
        nsLookupTask = Process()
        nsLookupTask.launchPath = "/usr/bin/nslookup"
        nsLookupTask.arguments = [ip]
        nsLookupOutFile = FileHandle(forWritingAtPath:"/Users/kurushetra/Desktop/nsLookup.txt")
        nsLookupTask.standardOutput = nsLookupOutFile
        NotificationCenter.default.addObserver(self, selector:#selector(lookUpFinish), name:Process.didTerminateNotification, object:nil)
        nsLookupTask.launch()

    }
    
    @objc func lookUpFinish() {
        print("lookUp finish")
        
        nsLookupTask.terminate()
        do   {
            let data = try  Data(contentsOf:nsLookupFileUrl)
            let dataString:String = String(data:data, encoding:.utf8)!
            nsLookupDelegate.lookUpFinish(result:dataString)
        }catch {
            print("ERROR: lookUp file not read it..")
        }
        
    }

    
}

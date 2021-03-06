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
protocol NetStatDelegate {
    func netStatFinish(result:String)
}

protocol ProcessDelegate {
    func procesFinishWith(nodes:[TraceRouteNode])
    func newDataFromProcess(data:String , processName:String)
}

extension DispatchQueue { //TODO: Cambiar de sitio
    
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









final class  Comands:IPLocatorDelegate,NodeFilledDelegate  {
    
    private init(){}
      static let shared = Comands()
    
    let fileExtractor:FileComandExtractor = FileComandExtractor()
    let filesManager:FilesManager = FilesManager.shared
    let dataBase:dataBaseManager = dataBaseManager()
    let ipLocator:IPLocator = IPLocator()

    var ipsLocatorFounded:[TraceRouteNode] = []
    
    //MARK: ---------------- PROCESS WITH COMAND  -------------------------
    var processDelegate:ProcessDelegate!
//    var processName:String!
    
     //MARK: ---------------- MTROUTE -------------------------
    var mtrRouteComand:String = "/bin/sh"
    var mtrRouteArgs:[String] = ["-c" , "echo nomeacuerdo8737 | sudo -S  ./mtr -rw -n www.google.com | awk '{print $2}'"]
//    , "| awk '{print $2}'"]
    
    
    
    //MARK: ---------------- TRACE_ROUTE  -------------------------
    var traceRouteComand:String =  "/usr/sbin/traceroute"
    var traceRouteArgs:[String] = ["-w 1" , "-m30" ,"www.google.com"]
    var traceRouteIpsDelegate:TraceRouteDelegate!
    var traceRouteTask =  Process()
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
    

    
    
    
    
    //MARK: ---------------- NETSTAT  -------------------------
    var netStatDelegate:NetStatDelegate!
    var netStatTask =  Process()
    var netStatOutFile:FileHandle!
    var netStatFileUrl:URL = URL(fileURLWithPath:"/Users/kurushetra/Desktop/netStat.txt")
    var netStatComand:String = "/bin/sh"
    var netStatArgs:[String] = ["-c" , "netstat -an  | grep ESTABLISHED"]
//    netstat   -an   | grep ESTABLISHED | awk '{print $5}'
    
    
    
    
    
    //MARK: ---------------- TCPKILL  -------------------------
    var tcpKillComand:String = "/bin/sh"
    var tcpKillArgs:[String] = ["-c","echo nomeacuerdo8737  | sudo -S tcpkill -i en4  host"]
//sudo   tcpkill -i en4  host 216.58.210.170
    
 
    
    
    
    //MARK: ---------------- PFCTL -------------------------
//    20  echo nomeacuerdo8737 | sudo -S   sudo pfctl -s info
//    21  echo nomeacuerdo8737 | sudo -S   pfctl -a com.apple -s rules
//    22  echo nomeacuerdo8737 | sudo -S   pfctl -a com.apple/250.ApplicationFirewall -s rules
//    23  echo nomeacuerdo8737 | sudo -S   pfctl -a  'com.apple/*' -sr
//    24  echo nomeacuerdo8737 | sudo -S   pfctl -a  "com.apple/*" -sr
//    25  echo nomeacuerdo8737 | sudo -S   pfctl -v -s Anchors
//    26  echo nomeacuerdo8737 | sudo -S   pfctl -a com.apple/200.AirDrop  -s rules
//    27  echo nomeacuerdo8737 | sudo -S   pfctl -a com.apple/200.AirDrop/Bonjour  -s rules
//    28  echo nomeacuerdo8737 | sudo -S   pfctl -s References

//    sudo  pfctl -d
//    sudo ifconfig pflog0 create
//     sudo tcpdump -n -e -ttt -i pflog0
//     sudo  pfctl -e -f  /etc/pf.conf
//    sudo   pfctl -t  -T badhosts  show 
//       sudo  pfctl -ss
//     sudo  pfctl -si
//      sudo  pfctl -sn
//    sudo   pfctl -t badhosts -T add 17.188.166.20
    
    
    
    
    
    //MARK: ---------------- MTROUTE -------------------------
//    echo nomeacuerdo8737 | sudo -S  ./mtr -rw -n  google.com |  awk '{print $2}'
// traceroute www.google.com | awk '{print $2,  $3}' 
    
    
    func nodeIpReady(node:TraceRouteNode) {
        ipsLocatorFounded.append(node)
    }
    
    func filled(node:TraceRouteNode) {
        processDelegate?.procesFinishWith(nodes:[node])
    }
    
    
    func netStat() {
        
        if netStatTask.isRunning {
            terminateNetStat()
        }
        filesManager.createFileAtPath(path:"/Users/kurushetra/Desktop/netStat.txt")
        
        DispatchQueue.background(delay: 0.0, background: {
            self.netStatTask = Process()
            self.netStatTask.launchPath = "/bin/sh"
            self.netStatTask.arguments = ["-c" , "netstat -an  | grep ESTABLISHED"]
            self.netStatOutFile = FileHandle(forWritingAtPath:"/Users/kurushetra/Desktop/netStat.txt")
            self.netStatTask.standardOutput = self.netStatOutFile
            
            self.netStatTask.launch()
//             self.netStatTask.waitUntilExit() //FIXME: Cambiar ha Observer..
        
        }, completion: {
            print("Completado")
//            let ips =  self.extractTraceRouteIps()
            self.netStatDelegate?.netStatFinish(result:"finish")
        })
    }
    
    func terminateNetStat() {
        netStatTask.terminate()
    }

    
    
    
    func runProcessWith(name:String, ip:String , delegate:ProcessDelegate) {
        
        var theArgs:String!
        
        if name == "mtRoute" {
           theArgs = mtrRouteArgs[0] + mtrRouteArgs[1] + ip + mtrRouteArgs[2]
           runProcessWith(comand:mtrRouteComand, args:[theArgs] , delegate:delegate)
        }
        
 
    }

    
    
    
    
    func runProcessWith(comand:String, args:[String] , delegate:ProcessDelegate) {
        
        
        filesManager.changeToWorkingPath(newPath:"/usr/local/sbin/")
        
        processDelegate = delegate
        ipsLocatorFounded = []
        
        let task = Process()
        task.launchPath = comand
        task.arguments = args
//        | awk '{print $3,  $5}'
        
        let pipe = Pipe()
        task.standardOutput = pipe
        let fh = pipe.fileHandleForReading
        fh.waitForDataInBackgroundAndNotify()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(receivedData), name: NSNotification.Name.NSFileHandleDataAvailable, object: nil)
        
       task.terminationHandler = {task -> Void in
            print("acabado")
        
        
        
           self.printResults()
        }
        task.launch()
    }
    
    
    
    func  printResults()  {
        
        
        OperationQueue.main.addOperation({
            
//            self.ipLocator.locatorDelegate = self
            
            let nodes:[TraceRouteNode] = self.fileExtractor.extractIpsFromMTRoute(ips:self.arrayResult[0])
            
            for node in nodes {
                node.nodeFilledDelegate = self
                node.fillNodeWithData()
//                if self.dataBase.fetchInfoFor(node:node).found == true {
//                    node.fillWithCoreDataNode(node:self.dataBase.fetchInfoFor(node:node).ip)
//                } else {
//                    self.ipLocator.fetchIpLocation(node:node)
//                }
            }

//            self.processDelegate?.procesFinishWith(nodes:self.ipsLocatorFounded)
            
//            var arr:[String] = self.arrayResult[0].components(separatedBy:"\n")
//            print(self.arrayResult[0])
        })

     }
    
    
    
    var arrayResult:[String] = []
    
    @objc func receivedData(notif : NSNotification) {
       
        let fh:FileHandle = notif.object as! FileHandle
       
        let data = fh.availableData
                if data.count > 1 {
            
           
           
            let string =  String(data: data, encoding: String.Encoding(rawValue: String.Encoding.ascii.rawValue))
            arrayResult.append(string!)
                    
                    OperationQueue.main.addOperation({
                        self.processDelegate.newDataFromProcess(data:string!, processName:"")
                     })
              fh.waitForDataInBackgroundAndNotify()
         }
    }
    
   
    
    
    
    
    
    //MARK: ---------------- TRACE_ROUTE  -------------------------
    func traceRouteTo(ip:String) {
        
        if traceRouteTask.isRunning {
            terminateTraceRoute()
        }
        
        DispatchQueue.background(delay: 0.0, background: {
            self.traceRouteTask = Process()
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

//
//  Comands.swift
//  AppController-scan
//
//  Created by Kurushetra on 27/8/17.
//  Copyright © 2017 Kurushetra. All rights reserved.
//

import Foundation



protocol ProcessDelegate {
    func procesFinish(processName:String)
    func procesFinishWith(node:Node)
    func procesFinishWith(node:Node, processName:String)
    func procesFinishWith(node:Node, processName:String, amountNodes:Int)
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
    
    private init(){
        dataBase.nodeFilledDelegate = self
    }
    static let shared = Comands()
    
    
    let fileExtractor:FileComandExtractor = FileComandExtractor()
    let filesManager:FilesManager = FilesManager.shared
    let dataBase:dataBaseManager = dataBaseManager()
    let ipLocator:IPLocator = IPLocator()
    var comandType:ComandType!
 
    
   
    var processDelegate:ProcessDelegate!
    var comandWorkingDelegate:ComandWorkingDelegate!
    
//    var traceRouteComand:String =  "/usr/sbin/traceroute"
//    var traceRouteArgs:[String] = ["-w 1" , "-m30" ,"www.google.com"]
//    var netStatArgs:[String] = ["-c" , "netstat -an  | grep ESTABLISHED"]
//    //    netstat   -an   | grep ESTABLISHED | awk '{print $5}'
//    //MARK: ---------------- TCPKILL  -------------------------
//    var tcpKillComand:String = "/bin/sh"
//    var tcpKillArgs:[String] = ["-c","echo nomeacuerdo8737  | sudo -S tcpkill -i en4  host"]
//    //sudo   tcpkill -i en4  host 216.58.210.170
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
    // sudo   pfctl -t badhosts -T delete 17.188.166.20
    
    
    
    var comandWorkingTimer:Timer!
    var arrayResult:[String] = []
    var nodeInUse:Node!
    
    func startTimerEvery(seconds:Double) {
        comandWorkingTimer = Timer.scheduledTimer(timeInterval: seconds, target: self, selector:#selector(timerComandWorking), userInfo: nil, repeats: true)
        
    }
    
    @objc func timerComandWorking() {  //FIXME: cambiar ha swift  @objc
        comandWorkingDelegate?.commandIsWorking(comandType:comandType)
    }
    
    func stopComandWorkingTimer() {
        
        if (comandWorkingTimer != nil) {
            comandWorkingTimer.invalidate()
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    func ipLocationReady(ipLocation:IPLocation) {
        
    }
    func nodeIpReady(node: Node) {
        
    }
 
    
    func filled(node:Node, amountIps:Int) { //TODO: acabar
        processDelegate?.procesFinishWith(node:node, processName: comandType.rawValue, amountNodes: amountIps)
    }
    func filled(node:Node) { //TODO: acabar
        processDelegate?.procesFinishWith(node:node, processName:comandType.rawValue)
    }
    
    
 
    
    
    func runComand(type:ComandType, node:Node, delegate:ProcessDelegate) {
        nodeInUse = node
        runComand(type:type, ip:node.number, delegate:delegate)
    }
    
    
    func runComand(type:ComandType, ip:String!, delegate:ProcessDelegate) {
        
        comandType = type
        arrayResult = []
        
        if type is ComandIp  {
            if ip == nil {
                print("runComand : Ip Es NILL")
                return
            }
        }
        
        switch type {
        case .tcpDump:
            run(comand:TcpDumpCom(), delegate:delegate)
        case .netStat:
            run(comand:NetStat(), delegate:delegate)
        case .traceRoute:
            run(comand:TraceRoute(withIp:ip), delegate:delegate)
        case .whois:
            run(comand:Whois(withIp:ip), delegate:delegate)
        case .nsLookup:
            run(comand:NsLookup(withIp:ip), delegate:delegate)
        case .mtRoute:
            run(comand:MtRoute(withIp:ip), delegate:delegate)
        case .fireWallState:
            run(comand:FireWallState(), delegate:delegate)
        case .addFireWallBadHosts:
            run(comand:AddFireWallBadHosts(withIp:ip), delegate:delegate)
        case .deleteFireWallBadHosts:
            run(comand:DeleteFireWallBadHosts(withIp:ip), delegate:delegate)
        case .fireWallStop:
            run(comand:FireWallStop(), delegate:delegate)
        case .fireWallStart:
            run(comand:FireWallStart(), delegate:delegate)
        case .fireWallBadHosts:
            run(comand:FireWallBadHosts(), delegate:delegate)
        default:
            print("")
        }
        comandWorkingDelegate = delegate as?  ComandWorkingDelegate
        startTimerEvery(seconds:0.5)
    }
    
    
    
    
    
    
    func run(comand:Comand, delegate:ProcessDelegate) {
        
        filesManager.changeToWorkingPath(newPath:"/usr/local/sbin/")//FIXME: cambiarlo segun comando
        processDelegate = delegate
 
        
        let task = Process()
        task.launchPath = comand.taskPath
        task.arguments = comand.taskArgs
        
        
        let pipe = Pipe()
        task.standardOutput = pipe
        let fh = pipe.fileHandleForReading
        fh.waitForDataInBackgroundAndNotify()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(receivedData), name: NSNotification.Name.NSFileHandleDataAvailable, object: nil)
        
        task.terminationHandler = {task -> Void in
            print("acabado")
            
            
            self.stopComandWorkingTimer()
            self.processResults()
        }
        task.launch()
    }
    
    
    func  processResults()  {
        
        OperationQueue.main.addOperation({
            
            switch self.comandType {
            case  .tcpDump:
                print("tcp dump finish")
            case  .fireWallState:
                if self.arrayResult.count >= 1 {
                    self.processDelegate.newDataFromProcess(data:self.arrayResult[0], processName:self.comandType!.rawValue)
                }
            case  .deleteFireWallBadHosts:
                self.processDelegate.procesFinish(processName:self.comandType!.rawValue)
            case  .fireWallStart:
                self.processDelegate.procesFinish(processName:self.comandType!.rawValue)
            case  .fireWallStop:
                self.processDelegate.procesFinish(processName:self.comandType!.rawValue)
            case  .fireWallBadHosts:
                if self.arrayResult.count >= 1 {
                    let ips = self.fileExtractor.findIpsIn(text:self.arrayResult[0])
                    for ip in ips! {
                       self.dataBase.nodeWith(ip:ip, amountIps:ips!.count)
                    }
                    
                }else if self.arrayResult.count == 0 {
                    self.processDelegate.newDataFromProcess(data:"0", processName:self.comandType!.rawValue)
                }
            case .addFireWallBadHosts:
                self.processDelegate.procesFinish(processName:self.comandType!.rawValue)
            default:
                  let ips = self.fileExtractor.findIpsIn(text:self.arrayResult[0])
                  for ip in ips! {
                    self.dataBase.nodeWith(ip:ip, amountIps:ips!.count)
                  }
                  
 
            }
        })
        
    }
    
    
    
    
    
    @objc func receivedData(notif : NSNotification) {
        
        let fh:FileHandle = notif.object as! FileHandle
        
        let data = fh.availableData
        if data.count > 1 {
            
            
            
            let string =  String(data: data, encoding: String.Encoding(rawValue: String.Encoding.ascii.rawValue))
            arrayResult.append(string!)
            
            
            if comandType == .tcpDump {
                let  ips = self.fileExtractor.findIpsIn(text:string!)
                if ips != nil {
                    for ip in ips! {
                         OperationQueue.main.addOperation({
                        self.dataBase.nodeFromDataBase(ip:ip)
                            print(ip)
                        })
                    }
                }
                
            }
            
//             OperationQueue.main.addOperation({
            //self.processDelegate.newDataFromProcess(data:string!, processName:"")
            //})
            fh.waitForDataInBackgroundAndNotify()
        }
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
    
 
    
 
    
}

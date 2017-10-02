//
//  ComandsStructures.swift
//  Kuru_TcpDump-scan
//
//  Created by Kurushetra on 2/10/17.
//  Copyright © 2017 Kurushetra. All rights reserved.
//

import Foundation

protocol ComandWorkingDelegate {
    func commandIsWorking(comandType:ComandType)
}

protocol Comand  {
    var taskPath:String{get set}
    var taskArgs:[String]{get set}
//    var fileUrl:URL{get set}
}

protocol ComandIp:Comand  {
    var ip:String{get set}
    init(withIp:String)
    mutating func addIp()
}


enum ComandType:String {
    case tcpDump,traceRoute,mtRoute,whois,nsLookup,blockIp,netStat,fireWallState,fireWallBadHosts,addFireWallBadHosts,deleteFireWallBadHosts,fireWallStop,fireWallStart
}


struct TcpDumpCom:Comand {
    var ip:String = ""
    var taskPath:String =  "/usr/sbin/tcpdump"
    var taskArgs:[String] = ["-i","en4","-n" ," not (src net 192.168.8.1 and dst net 192.168.8.100) and not  (src net 192.168.8.100 and dst net 192.168.8.1) and not (src net 192.168.8.1 and dst net 239.255.255.250)"]
//    var fileUrl:URL = URL(fileURLWithPath:"/Users/kurushetra/Desktop/traceRoute.txt")
    
    mutating func block(ip:String) {
        let notIpArgs:String = "and not (src net " + ip + " and dst net " + ip + ")"
        self.taskArgs.append(notIpArgs)
    }
}



struct TraceRoute:ComandIp {
    var ip:String = ""
    var taskPath:String =  "/usr/sbin/traceroute"
    var taskArgs:[String] = ["-w 1" , "-m30" ,"www.google.com"]
//    var fileUrl:URL = URL(fileURLWithPath:"/Users/kurushetra/Desktop/traceRoute.txt")
    
    init(withIp:String) {
        self.ip = withIp
        addIp()
    }
    
    mutating func addIp() {
        self.taskArgs[2] = self.ip
    }
}


struct NsLookup:ComandIp {
    var ip:String = ""
    var taskPath:String =  "/usr/bin/nslookup"
    var taskArgs:[String] = []
//    var fileUrl:URL = URL(fileURLWithPath:"/Users/kurushetra/Desktop/traceRoute.txt")
    
    init(withIp:String) {
        self.ip = withIp
        addIp()
    }
    
    mutating func addIp() {
        self.taskArgs = [self.ip]
    }
}


struct Whois:ComandIp {
    var ip:String = ""
    var taskPath:String =  "/usr/sbin/traceroute"
    var taskArgs:[String] = []
//    var fileUrl:URL = URL(fileURLWithPath:"/Users/kurushetra/Desktop/traceRoute.txt")
    
    init(withIp:String) {
        self.ip = withIp
        addIp()
    }
    
    mutating func addIp() {
        self.taskArgs = [self.ip]
    }
}


struct MtRoute:ComandIp {
    
    var ip:String = ""
    var taskPath:String =  "/bin/sh"
    var taskArgs:[String] = ["-c" , "echo nomeacuerdo8737 | sudo -S  ./mtr -rw -n ??? | awk '{print $2}'"]
//    var fileUrl:URL = URL(fileURLWithPath:"/Users/kurushetra/Desktop/traceRoute.txt")
    
    init(withIp:String) {
        self.ip = withIp
        addIp()
    }
    
    mutating func addIp() {
        let comand:String = taskArgs[1]
        let comandWithIp:String = comand.replacingOccurrences(of:"???", with:self.ip)
        self.taskArgs[1] = comandWithIp
        
    }
}


struct NetStat:Comand  {
    var taskPath:String =  "/bin/sh"
    var taskArgs:[String] = ["-c" , "netstat -an  | grep ESTABLISHED"]
//    var fileUrl:URL = URL(fileURLWithPath:"/Users/kurushetra/Desktop/netStat.txt") //FIXME: no lleva file ??
}


struct FireWallStart:Comand  {
    var taskPath:String =  "/bin/sh"
    var taskArgs:[String] = ["-c" , "echo nomeacuerdo8737 | sudo -S pfctl -e -f  /etc/pf.conf"]
//    var fileUrl:URL = URL(fileURLWithPath:"/Users/kurushetra/Desktop/netStat.txt") //FIXME: no lleva file ??
}

struct FireWallStop:Comand  {
    var taskPath:String =  "/bin/sh"
    var taskArgs:[String] = ["-c" , "echo nomeacuerdo8737 | sudo -S  pfctl -d"]
//    var fileUrl:URL = URL(fileURLWithPath:"/Users/kurushetra/Desktop/netStat.txt") //FIXME: no lleva file ??
}


struct FireWallState:Comand  {
    var taskPath:String =  "/bin/sh"
    var taskArgs:[String] = ["-c" , "echo nomeacuerdo8737 | sudo -S pfctl  -s info | grep Status"]
//    var fileUrl:URL = URL(fileURLWithPath:"/Users/kurushetra/Desktop/netStat.txt") //FIXME: no lleva file ??
}


struct FireWallBadHosts:Comand  {
    var taskPath:String =  "/bin/sh"
    var taskArgs:[String] = ["-c" , "echo nomeacuerdo8737 | sudo -S pfctl -t badhosts -T show"]
//    var fileUrl:URL = URL(fileURLWithPath:"/Users/kurushetra/Desktop/netStat.txt") //FIXME: no lleva file ??
}


struct AddFireWallBadHosts:ComandIp  {
    
    var ip:String = ""
    var taskPath:String =  "/bin/sh"
    var taskArgs:[String] = ["-c" , "echo nomeacuerdo8737 | sudo -S pfctl  -t badhosts -T add ???"]
//    var fileUrl:URL = URL(fileURLWithPath:"/Users/kurushetra/Desktop/netStat.txt") //FIXME: no lleva file ??
    
    init(withIp:String) {
        self.ip = withIp
        addIp()
    }
    
    mutating func addIp() {
        let comand:String = taskArgs[1]
        let comandWithIp:String = comand.replacingOccurrences(of:"???", with:self.ip)
        self.taskArgs[1] = comandWithIp
        
    }
}


struct DeleteFireWallBadHosts:ComandIp  {
    
    var ip:String = ""
    var taskPath:String =  "/bin/sh"
    var taskArgs:[String] = ["-c" , "echo nomeacuerdo8737 | sudo -S pfctl  -t badhosts -T delete ???"]
//    var fileUrl:URL = URL(fileURLWithPath:"/Users/kurushetra/Desktop/netStat.txt") //FIXME: no lleva file ??
    
    init(withIp:String) {
        self.ip = withIp
        addIp()
    }
    
    mutating func addIp() {
        let comand:String = taskArgs[1]
        let comandWithIp:String = comand.replacingOccurrences(of:"???", with:self.ip)
        self.taskArgs[1] = comandWithIp
        
    }
}



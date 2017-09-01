//
//  TcpDump.swift
//  Kuru_TcpDump-scan
//
//  Created by Kurushetra on 30/8/17.
//  Copyright © 2017 Kurushetra. All rights reserved.
//

import Foundation
import CoreData
import Cocoa


protocol  TcpDumpDelegate {
    func newIpComing(ips:[Node])
    func newConection(ip:Node)
//    func newNode(node:TraceRouteNode)
    func newPackage()
    func packageProcessed(number:Int)
}

enum PackagesMode:Int {
    case off,on
}
enum ProcessedMode:Int {
    case off,on
}
enum FilterInTcpDumpCommand:Int {
    case off,on
}


class TcpDump {
    
    
    let appDelegate = NSApplication.shared().delegate  as! AppDelegate
    let managedContext:NSManagedObjectContext!
    
    
    var tcpDumpDelegate:TcpDumpDelegate!
    
    //MARK: ---------------- TCP_DUMP  -------------------------
    var countPackagesMode:PackagesMode = PackagesMode.off
    var countProcessedMode:ProcessedMode = ProcessedMode.off
    var packagesProcessed:Int = 0
    var filterInTcpDumpCommand:FilterInTcpDumpCommand = FilterInTcpDumpCommand.off
    var tcpDumpTask =  Process()
    var tcpDumpOutFile:FileHandle!
    var tcpDumpFileUrl:URL = URL(fileURLWithPath:"/Users/kurushetra/Desktop/netstat2.txt")
    var args = ["-i","en4","-n" ," not (src net 192.168.8.1 and dst net 192.168.8.100) and not  (src net 192.168.8.100 and dst net 192.168.8.1) and not (src net 192.168.8.1 and dst net 239.255.255.250)"]
    var isScanStoped:Bool = false

    var extractLinesTimer:Timer!
      var getIpLocationsTimer:Timer!
    
    var newConection:Conection = Conection()
    var dataBaseMode:DataBaseMode = DataBaseMode.on
    var ipsFoundOffMode:[Node] = []
    var ipsFound:[Node] = []
    var conectionsToShow:[Conection] = []
     var ipLocatorReady:Bool = true
    
    
    enum  DataBaseMode:Int {
        case on,off
    }
    
    enum  Direction:Int {
        case coming,going
    }
    
    //MARK: ---------------- INIT -------------------------
    init() {
        managedContext = self.appDelegate.persistentContainer.viewContext
        
//        ipLocator.locatorDelegate = self
    }

    func startTcpScan() {
        
        isScanStoped = false
        getIps()
        
        
        executeTcpDump()
        startTimerEvery(seconds:0.1)
        startTimerLocationsEvery(seconds:1.0)
        
    }

    func getIps() {
        
        //        ipsFounded = []
        ipsFound = []
        
        let fetchRequest: NSFetchRequest<Node> = Node.fetchRequest()
        
        do {
            let searchResults = try managedContext.fetch(fetchRequest)
            print ("num of results = \(searchResults.count)")
            
            for ip in searchResults as [Node] {
                //                ipsFounded.append(ip.number!)
                ipsFound.append(ip)
                print("\(String(describing: ip.value(forKey: "number")))")
            }
            if ipsFound.count >= 1 {
                tcpDumpDelegate?.newIpComing(ips:ipsFound)
            }
        } catch {
            print("Error with request: \(error)")
        }
    }

    
    func dataBaseModeOff() {
        dataBaseMode = DataBaseMode.off
        ipsFoundOffMode = []
        ipsFound = []
        tcpDumpDelegate?.newIpComing(ips:ipsFoundOffMode)
    }
    
    
    
    
    
    //MARK: ---------------- CORE DATA -------------------------
    func cleanDataBase() {
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Node")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        do {
            try managedContext.execute(request)
            
        } catch {
            // Error Handling
        }
        ipsFound.removeAll()
        tcpDumpDelegate?.newIpComing(ips:ipsFound)
    }

    
    
    
    
    
    
    
    func executeTcpDump()   {
        
        if filterInTcpDumpCommand == FilterInTcpDumpCommand.on {
            if tcpDumpTask.isRunning {
                terminateCommand()
            }
        }
        
        tcpDumpTask = Process()
        tcpDumpTask.launchPath = "/usr/sbin/tcpdump"
        tcpDumpTask.arguments = args
        tcpDumpOutFile = FileHandle(forWritingAtPath:"/Users/kurushetra/Desktop/netstat2.txt")
        tcpDumpTask.standardOutput = tcpDumpOutFile
        tcpDumpTask.launch()
    }
    
    
    func terminateCommand() {
        isScanStoped = true
        tcpDumpTask.terminate()
    }

    
    
    
    func startTimerEvery(seconds:Double) {
        extractLinesTimer = Timer.scheduledTimer(timeInterval: seconds, target: self, selector:#selector(timerSelector), userInfo: nil, repeats: true)
        
    }
    
    
    @objc func timerSelector() {  //FIXME: cambiar ha swift  @objc
        
        decomposeTcpLine()
        
        if countPackagesMode == PackagesMode.on {
             tcpDumpDelegate?.newPackage()
        }
        
        
    }
    
    func stopTimer() {
        
        if (extractLinesTimer != nil) {
            extractLinesTimer.invalidate()
        }
    }

    
    //MARK: ---------------- LINES  -------------------------
    
    
    func decomposeTcpLine() {
        
        //        if ipLocatorReady == true {
        
        var arrayFields = tcpDumpFileLine.components(separatedBy:" ")
        var isFound:Bool = false
        
        if arrayFields.count <= 3 {
            print("--------")
            removeLine()
            return
        }
        
        if arrayFields[1] == "ARP," {
            print("---- ARP ----")
            removeLine()
            return //FIXME: Coger paquete y conexion y borrar linea
        }
        
        if arrayFields[1] == "options" {
            print("---- options ----")
            removeLine()
            return //FIXME: Coger paquete y conexion y borrar linea
        }
        if arrayFields[1] == "IP6" {
            print("---- IP6 ----")
            removeLine()
            return //FIXME: Coger paquete y conexion y borrar linea
        }
        //        if arrayFields[1] == "IP" {
        //           print("---- IP ----")
        //        }
        
        
        if arrayFields.count >= 5 {
            print("++++++++")
            let tmpTime = arrayFields[0]
            var arrayTime = tmpTime.components(separatedBy:".")
            let time = arrayTime[0]
            
            let comingIP:String = arrayFields[2]
            let goingIP:String = arrayFields[4]
            
            
            
            let caracter:CharacterSet = CharacterSet.init(charactersIn:":")
            var comIpArray:[String] = comingIP.components(separatedBy:".")
            
            if comIpArray.count <= 3 { //FIXME: quitar :45 del puerto y coger ip borrar linea
                removeLine()
                
                if countProcessedMode == ProcessedMode.on {
                    countProcessedPacages()
                }
                return
            }
            
            let ipComing:String = comIpArray[0] + "." + comIpArray[1] + "." + comIpArray[2] + "." + comIpArray[3]
            let cip =  ipComing.trimmingCharacters(in:caracter)
            
            
            var goIpArray:[String] = goingIP.components(separatedBy:".")
            if goIpArray.count <= 3 {
                removeLine()
                if countProcessedMode == ProcessedMode.on {
                    countProcessedPacages()
                }
                
                return
            }
            
            let ipGoing:String = goIpArray[0] + "." + goIpArray[1] + "." + goIpArray[2] + "." + goIpArray[3]
            let gip =  ipGoing.trimmingCharacters(in:caracter)
            
            newConection.comIp = cip
            newConection.goIp = gip
            newConection.conectionTime = Double(time)
            
            
            
            if cip != "192.168.8.1" && cip != "192.168.8.100" {
                
                if cip.characters.count <= 17 {
                    
                    
                    for ip in ipsToCheck() {
                        
                        if ip.number == cip {
                            isFound = true
                        }
                    }
                    
                    if isFound == false {
                        newIpWith(number:cip)
                        //                        fetchIpLocation(ipString:cip , direction:Direction.coming)
                        //                        ipLocatorReady = false
                    }
                }
                
            }
            
            isFound = false
            
            if gip != "192.168.8.1" && gip != "192.168.8.100" {
                
                if gip.characters.count <= 17 {
                    
                    for ip in ipsToCheck() {
                        
                        if ip.number == gip {
                            
                            isFound = true
                        }
                    }
                    if isFound == false {
                        //                        fetchIpLocation(ipString:gip , direction:Direction.going)
                        newIpWith(number:gip)
                        
                        
                        //                        ipLocatorReady = false
                    }
                    
                }
                
            }
            
            removeLine()
            
            if countProcessedMode == ProcessedMode.on {
                countProcessedPacages()
            }
            
            
        }
        //        }
    }
    

    
    
    var  tcpDumpFileLine:String {
        
        var arrayData:[String] = ["No data"]
        var  data:Data!
        
        do   {
            data = try  Data(contentsOf:tcpDumpFileUrl)
            let dataString:String = String(data:data, encoding:.utf8)!
            arrayData = dataString.components(separatedBy:"\n")
            
            if arrayData.count >= 2 { //FIXME: Cambiar ha ??
                return arrayData[0]
            }else {
                if isScanStoped {
                    arrayData[0] = "No data"
                    stopTimer()
                    stopLocationsTimer()
                    return arrayData[0]
                }
            }
            
        }catch {
            print("no hay data")
        }
        return arrayData[0]
        
    }

    
    func stopLocationsTimer() {
        
        if (getIpLocationsTimer != nil) {
            getIpLocationsTimer.invalidate()
        }
    }

    
    
    func removeLine() {
        self.removeLinesFromFile(fileURL:tcpDumpFileUrl, numLines:1)
    }

    func removeLinesFromFile(fileURL: URL, numLines: Int) {
        
        do {
            let data = try NSData(contentsOf: fileURL , options: .mappedIfSafe)
            let nl = "\n".data(using: String.Encoding.utf8)!
            var lineNo = 0
            var pos = 0
            
            while lineNo < numLines {
                let range = data.range(of: nl, options: [], in: NSMakeRange(pos,data.length - pos))
                if range.location == NSNotFound {
                    return
                }
                lineNo += 1
                pos = range.location + range.length
            }
            let trimmedData = data.subdata(with: NSMakeRange(pos, data.length - pos))
            try! trimmedData.write(to: fileURL)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func countProcessedPacages() {
        packagesProcessed += 1
        tcpDumpDelegate?.packageProcessed(number:packagesProcessed)
    }

    
    func ipsToCheck() -> [Node] {
        
        var ipsToCheck:[Node] = []
        
        if dataBaseMode == DataBaseMode.on {
            ipsToCheck = ipsFound
        }
        if dataBaseMode == DataBaseMode.off {
            ipsToCheck = ipsFoundOffMode
        }
        
        return ipsToCheck
    }

    
    
    
    func newIpWith(number:String) {
        
        if filterInTcpDumpCommand == FilterInTcpDumpCommand.on {
            excludeIpFromTcpDump(ip:number)
        }
        
        let newIp:Node = newIpEntity()
        newIp.number = number
        
        
        if dataBaseMode == DataBaseMode.on {
            
            ipsFound.append(newIp)
             self.tcpDumpDelegate?.newIpComing(ips:self.ipsFound)
            
            do {
                try self.managedContext.save()
                
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
        }else {
            ipsFoundOffMode.append(newIp)
            self.tcpDumpDelegate?.newIpComing(ips:self.ipsFoundOffMode)
        }
    }
    
    
    
    func excludeIpFromTcpDump(ip:String) {
        
        tcpDumpTask.terminate()
        
        if tcpDumpTask.isRunning {
            tcpDumpTask.terminate()
        }
        
        let notIpArgs:String = "and not (src net " + ip + " and dst net " + ip + ")"
        args.append(notIpArgs)
        
        if isScanStoped == false {
            executeTcpDump()
        }
    }
    
    func  newIpEntity() -> Node {
        let entity = NSEntityDescription.entity(forEntityName: "Node", in: self.managedContext)!
        let ip = NSManagedObject(entity: entity,insertInto: self.managedContext) as! Node
        return ip
    }

    
    
    //MARK: ---------------- TIMER GET LOCATIONS -------------------------
    
    func startTimerLocationsEvery(seconds:Double) {
        getIpLocationsTimer = Timer.scheduledTimer(timeInterval: seconds, target: self, selector:#selector(timerLocationsSelector), userInfo: nil, repeats: true)
        
    }
    
    
    @objc func timerLocationsSelector() {  //FIXME: cambiar ha swift  @objc
        
        completeIPs()
    }
    
    

    
       //MARK: ---------------- LOCATION  -------------------------
    
    func  completeIPs() {
        
        for ip in ipsToCheck() {
            if ip.isFilled() == false {
                fetchIpLocation(ip:ip , direction:Direction.coming) //FIXME: quitar comming
                return
            }
        }
        
    }
    //    ipconfig getifaddr en4
    //    curl ipecho.net/plain ; echo
    //    /usr/local/Cellar/mtr
    //     curl ip-api.com/json/95.126.27.146
    //    "http://freegeoip.net/json/" + "\(ipString)")
    
    func fetchIpLocation(ip:Node, direction:Direction) {
        
        ipLocatorReady = false
        let ipNumber:String = ip.number!
        
        let url = URL(string:"http://ip-api.com/json/" + "\(ipNumber)")
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print(error ?? "Error in fetchIpLocation")
            }else{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                    
                    //                    let lon:String = String(describing: json["longitude"] as! NSNumber)
                    //                    print(lon)
                    
                    OperationQueue.main.addOperation({
                        
                        //                       ["latitude": 37.3042, "city": Cupertino, "country_name": United States, "country_code": US, "ip": 17.130.74.5, "zip_code": 95014, "region_code": CA, "longitude": -122.0946, "metro_code": 807, "region_name": California, "time_zone": America/Los_Angeles]
                        
                        if json.count <= 3 {
                            return
                        }
                        
                        ip.city = json["city"] as? String
                        //                        ip.number = ipString
                        ip.latitud = Double(json["lat"] as! Double)
                        ip.longitude = Double(json["lon"] as! Double)
                        ip.country  = json["country"] as? String
                        ip.aso = json["regionName"] as? String
                        
                        
                        ip.anotation = IpAnotation()
                        ip.anotation.title =  json["as"] as? String
                        ip.anotation.subtitle = ip.number
                        ip.anotation.coordinate.latitude = ip.latitud
                        ip.anotation.coordinate.longitude = Double(ip.longitude)
                        
                        
                        //                        node.aso  = json["as"] as? String
                        //                        node.city = json["city"] as? String
                        //                        node.country = json["country"] as? String
                        //                        node.countryCode = json["countryCode"] as? String
                        //                        node.isp = json["isp"] as? String
                        //                        node.lat = json["lat"] as? Double
                        //                        node.lon = json["lon"] as? Double
                        //                        node.org = json["org"] as? String
                        //                        node.region = json["region"] as? String
                        //                        node.regionName = json["regionName"] as? String
                        //                        node.status = json["status"] as? String
                        //                        node.timezone = json["timezone"] as? String
                        //                        node.zip = json["zip"] as? String
                        //
                        
                        self.tcpDumpDelegate?.newIpComing(ips:self.ipsToCheck())
                        self.tcpDumpDelegate?.newConection(ip:ip)
                        
                        
                        
                        
                        
                        self.ipLocatorReady = true
                        
                        
                        
                        //                        print(ip.longitude ??  "no set")
                        if direction == Direction.coming {
                            self.newConection.comIpLatitud = String(ip.latitud)
                            self.newConection.comIpLongitude = String(ip.longitude)
                        }
                        if direction == Direction.going {
                            self.newConection.goIpLatitud = String(ip.latitud)
                            self.newConection.goIpLongitude = String(ip.longitude)
                        }
                        
                        if self.newConection.isFilled() {
                            self.newConectionReadyToShow()
                        }
                        
                        do {
                            try self.managedContext.save()
                            
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
                        
                        
                    })
                    
                }catch let error as NSError{
                    print(error)
                }
            }
        }).resume()
    }
    
    func newConectionReadyToShow() {
        
        conectionsToShow.append(newConection)
        newConection = Conection()
        print(conectionsToShow)
    }


}

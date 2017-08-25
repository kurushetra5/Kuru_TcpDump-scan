//
//  KuTcp_Scaner.swift
//  Kuru_TcpDump-scan
//
//  Created by Kurushetra on 20/8/17.
//  Copyright © 2017 Kurushetra. All rights reserved.
//

import Foundation
import Cocoa


protocol  IPsDelegate {
    func newIpComing(ips:[String])
}



class Kuru_TcpDump   {
    
    //MARK: ---------------- VARS -------------------------
    
    let appDelegate = NSApplication.shared().delegate  as! AppDelegate
    let managedContext:NSManagedObjectContext!
    var ipsDelegate:IPsDelegate?
    let tcpDumpTask =  Process()
    var tcpDumpOutFile:FileHandle!
    var ipsFounded:[String] = []
    var extractLinesTimer:Timer!
    var newConection:Conection = Conection()
    var conectionsToShow:[Conection] = []
    
    
    var  tcpDumpFileLine:String {
        
       var arrayData:[String] = ["No data"]
       var  data:Data!
        
        do   {
            data = try  Data(contentsOf:URL(fileURLWithPath:"/Users/kurushetra/Desktop/netstat2.txt"))
            let dataString:String = String(data:data, encoding:.utf8)!
            arrayData = dataString.components(separatedBy:"\n")
            
            if arrayData.count >= 2 { //FIXME: Cambiar ha ??
               return arrayData[0]
            }else {
               arrayData[0] = "No data"
               return arrayData[0]
            }

        }catch {
            print("no hay data")
        }
         return arrayData[0]
        
    }
    
    
    //MARK: ---------------- INIT -------------------------
      init() {
        managedContext = self.appDelegate.persistentContainer.viewContext
        getIps()
 
    }
    
    
    //MARK: ---------------- START -------------------------
    
    func startTcpScan() {
//        cleanDataBase()
        
        startTimerEvery(seconds:0.1)
        executeTcpDump()
    }
    
    
    
    
    
    //MARK: ---------------- CORE DATA -------------------------
    func cleanDataBase() {
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "IpAdress")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        do {
            try managedContext.execute(request)
            
        } catch {
            // Error Handling
        }
    }
    
    
    
    func getIps() {
        
        ipsFounded = []
        
        let fetchRequest: NSFetchRequest<IpAdress> = IpAdress.fetchRequest()
 
        do {
            let searchResults = try managedContext.fetch(fetchRequest)
            print ("num of results = \(searchResults.count)")
            
            for ip in searchResults as [IpAdress] {
                ipsFounded.append(ip.number!)
                print("\(String(describing: ip.value(forKey: "number")))")
            }
            ipsDelegate?.newIpComing(ips:ipsFounded)
            
        } catch {
            print("Error with request: \(error)")
        }
    }
    
    
    
    func fetchCoreDataInfoForNew(conection:Conection , direction:String) {
        
        if direction == "coming" {
            
            let fetchRequest: NSFetchRequest<IpAdress> = IpAdress.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "number == %@",conection.comIp)
           
            do {
                let searchResults = try managedContext.fetch(fetchRequest)
                print ("num of results = \(searchResults.count)")
                
                for ip in searchResults as [IpAdress] {
                    newConection.comIpLatitud = ip.value(forKey: "latitud") as! String
                    newConection.comIpLongitude = ip.value(forKey: "longitude") as! String
                }
            } catch {
                print("Error with request: \(error)")
            }
        }
        
        if direction == "going" {
            
            let fetchRequest: NSFetchRequest<IpAdress> = IpAdress.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "number == %@", conection.goIp)
            
            do {
                let searchResults = try managedContext.fetch(fetchRequest)
                print ("num of results = \(searchResults.count)")
                
                for ip in searchResults as [IpAdress] {
                    newConection.goIpLatitud = ip.value(forKey: "latitud") as! String
                    newConection.goIpLongitude = ip.value(forKey: "longitude") as! String
                    
                    
                    //                    print("\(String(describing: ip.value(forKey: "number")))")
                }
            } catch {
                print("Error with request: \(error)")
            }
        }
        
        
        if self.newConection.isFilled() {
            self.newConectionReadyToShow()
        }
        
    }
    
    
    
    
    
    
    
    
    //MARK: ---------------- TIMER EXTRACT LINES -------------------------
    
    func startTimerEvery(seconds:Double) {
        extractLinesTimer = Timer.scheduledTimer(timeInterval: seconds, target: self, selector:#selector(timerSelector), userInfo: nil, repeats: true)
        
    }
    
    
    @objc func timerSelector() {  //FIXME: cambiar ha swift  @objc
        
       decomposeTcpLine()
    }
    
    
    
    func stopTimer() {
        
        if (extractLinesTimer != nil) {
            extractLinesTimer.invalidate()
        }
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
    
    
    
    
    
    //MARK: ---------------- LINES  -------------------------
    
    
    func decomposeTcpLine() {
        
        var arrayFields = tcpDumpFileLine.components(separatedBy:" ")
        
        if arrayFields.count <= 3 {
            removeLine()
            return
        }
        
        if arrayFields[1] == "ARP" {
            removeLine()
            return //FIXME: Coger paquete y conexion y borrar linea
        }
        if arrayFields[1] == "options" {
            removeLine()
            return //FIXME: Coger paquete y conexion y borrar linea
        }
        if arrayFields[1] == "IP6" {
            removeLine()
            return //FIXME: Coger paquete y conexion y borrar linea
        }
        if arrayFields.count >= 5 {
            
            let tmpTime = arrayFields[0]
            var arrayTime = tmpTime.components(separatedBy:".")
            let time = arrayTime[0]
            
            let comingIP:String = arrayFields[2]
            let goingIP:String = arrayFields[4]
            
            
            
            let caracter:CharacterSet = CharacterSet.init(charactersIn:":")
            
            var comIpArray:[String] = comingIP.components(separatedBy:".")
            
            if comIpArray.count <= 3 { //FIXME: quitar :45 del puerto y coger ip borrar linea
                return
            }
            
            let ipComing:String = comIpArray[0] + "." + comIpArray[1] + "." + comIpArray[2] + "." + comIpArray[3]
            let cip =  ipComing.trimmingCharacters(in:caracter)
            
            
            var goIpArray:[String] = goingIP.components(separatedBy:".")
            if goIpArray.count <= 3 {
                return
            }
            
            let ipGoing:String = goIpArray[0] + "." + goIpArray[1] + "." + goIpArray[2] + "." + goIpArray[3]
            let gip =  ipGoing.trimmingCharacters(in:caracter)
            
            newConection.comIp = cip
            newConection.goIp = gip
            newConection.conectionTime = Double(time)
            
            
            if cip.characters.count < 17 {
                
                if ipsFounded.index(of:cip) == nil {
                    ipsFounded.append(cip)
                    fetchIpLocation(ipString:cip , direction:"comming")
                    ipsDelegate?.newIpComing(ips:ipsFounded)
                }else {
                    fetchCoreDataInfoForNew(conection:newConection , direction:"comming")
                }
            }
            
            if gip.characters.count < 17 {
                
                if ipsFounded.index(of:gip) == nil {
                    ipsFounded.append(gip)
                    fetchIpLocation(ipString:gip , direction:"going")
                    ipsDelegate?.newIpComing(ips:ipsFounded)
                }else {
                    fetchCoreDataInfoForNew(conection:newConection , direction:"comming")
                }
                
            }
            
            
            removeLine()
            
            
        }
        
    }
    
    
    func removeLine() {
        
        let url:URL = URL.init(fileURLWithPath:"/Users/kurushetra/Desktop/netstat2.txt")
        self.removeLinesFromFile(fileURL:url, numLines:1)
        print("------ line  processed and REMOVED -------")
        print(ipsFounded)
        
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
    
    
    
    
    
    //MARK: ---------------- LOCATION  -------------------------
    
    
    func fetchIpLocation(ipString:String, direction:String) {
        
        let url = URL(string:"http://freegeoip.net/json/" + "\(ipString)")
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print(error ?? "Error in fetchIpLocation")
            }else{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                    
                    OperationQueue.main.addOperation({
                        
                       
                        let entity = NSEntityDescription.entity(forEntityName: "IpAdress", in: self.managedContext)!
                        let ip = NSManagedObject(entity: entity,insertInto: self.managedContext) as! IpAdress
                        ip.city = json["city"] as? String
                        ip.number = ipString
                        ip.latitud = Double((json["latitude"] as? Double)!)
                        ip.longitude = json["longitude"] as? String
                        ip.country  = json["country"] as? String
                        ip.adress = json["adress"] as? String
                        print(ip.city ?? "City no set")
                        
                        
                        if direction == "coming" {
                            self.newConection.comIpLatitud = String(ip.latitud)
                            self.newConection.comIpLongitude = ip.longitude
                        }
                        if direction == "going" {
                            self.newConection.goIpLatitud = String(ip.latitud)
                            self.newConection.goIpLongitude = ip.longitude
                        }
                        
                        if self.newConection.isFilled() {
                            self.newConectionReadyToShow()
                        }
                        
                        do {
                            try self.managedContext.save()
                            //                                people.append(ip)
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
    
    
    
    
    //MARK: ---------------- CONECTIONS  -------------------------
    func newConectionReadyToShow() {
        
        conectionsToShow.append(newConection)
        newConection = Conection()
        print(conectionsToShow)
    }
    
    
    //MARK: ---------------- WHOIS  -------------------------
    func whoisTo(ip:String) {
        
    }
    
    //MARK: ---------------- NSLOOKUP  -------------------------
    func nsLookupTo(ip:String) {
        
    }
    
    //MARK: ---------------- TRACE_ROUTE  -------------------------
    func traceRouteTo(ip:String) {
        
    }
   
    
}

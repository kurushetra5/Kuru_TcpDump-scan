//
//  KuTcp_Scaner.swift
//  Kuru_TcpDump-scan
//
//  Created by Kurushetra on 20/8/17.
//  Copyright © 2017 Kurushetra. All rights reserved.
//

import Foundation
import Cocoa


class Kuru_TcpDump {
    
    
    let appDelegate = NSApplication.shared().delegate  as! AppDelegate
    let task =  Process()
    var output:FileHandle!
//    var oldLinesCount = 0
//    var numberOfProcesedLines = 0
    var ips:[String] = []
    var timer:Timer!
    
//    var linesToProceses:Int {
//        return oldLinesCount - numberOfProcesedLines
//    }
    
//    var numberOfNewLines:Int {
//        return actualLinesCount - oldLinesCount
//    }
    
//    var actualLinesCount:Int {
//        return countLines(filePath:"/Users/kurushetra/Desktop/netstat2.txt")
//    }
    
    
    
    
    
    
    
    func startTcpScan() {
        
//        fetchIpLocation(ip:"216.58.211.228")
        
              getIps()
//                startTimerEvery(seconds:0.1)
//                executeTcpDump()
    }
    
    
    func getIps() {
       
        ips = []

        
        let fetchRequest: NSFetchRequest<IpAdress> = IpAdress.fetchRequest()
         let managedContext = self.appDelegate.persistentContainer.viewContext
        do {
            let searchResults = try managedContext.fetch(fetchRequest)
            print ("num of results = \(searchResults.count)")
            
            for ip in searchResults as [IpAdress] {
                ips.append(ip.number!)
                print("\(String(describing: ip.value(forKey: "number")))")
            }
        } catch {
            print("Error with request: \(error)")
        }
    }
    
    
    
    
    
    func startTimerEvery(seconds:Double) {
        timer = Timer.scheduledTimer(timeInterval: seconds, target: self, selector:#selector(timerSelector), userInfo: nil, repeats: true)
        
    }
    
    
    @objc func timerSelector() {  //FIXME: cambiar ha swift  @objc
        
        extractNewLines()
    }
    
    func stopTimer() {
        
        if (timer != nil) {
            timer.invalidate()
        }
    }

    
    
    
    
    
    
    func executeTcpDump()   {
        
        task.launchPath = "/usr/sbin/tcpdump"
        task.arguments = ["-i","en4","-n"]
        output = FileHandle(forWritingAtPath:"/Users/kurushetra/Desktop/netstat2.txt")
        task.standardOutput = output
        task.launch()
        
    }
    func terminateCommand() {
        task.suspend()
        task.terminate()
    }

    
    
    
    
    
    
    
    
    
//    func checkForNewLine() {
//        
//        if actualLinesCount > oldLinesCount {
//            
//            
//            oldLinesCount = actualLinesCount
//            print("\(numberOfNewLines)" + " -- new lines")
//            extractNewLines()
//        } else {
//            
//            if needToProcesLines() {
//                extractNewLines()
//            }
//        }
//        
//    }
    
    
//    func needToProcesLines() -> Bool {
//        
//        if numberOfProcesedLines < linesToProceses {
//            return true
//        }else {
//            return false
//        }
//    }
    
    
    
    
    
    func extractNewLines() {
        
        var arrayData:[String] = []
        
        do   {
            let data:Data = try  Data(contentsOf:URL(fileURLWithPath:"/Users/kurushetra/Desktop/netstat2.txt"))
            let dataString:String = String(data:data, encoding:.utf8)!
            arrayData = dataString.components(separatedBy:"\n")
            
            if arrayData.count >= 2 {
                decomposeTcpLine(stringLine:arrayData[0])
            }
        }catch {
            print("no hay data")
        }
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    func decomposeTcpLine(stringLine:String) {
        
        var arrayFields = stringLine.components(separatedBy:" ")
        
        if arrayFields.count >= 5 {
            
            let tmpTime = arrayFields[0]
            var arrayTime = tmpTime.components(separatedBy:".")
            var time = arrayTime[0]
            
            let comingIP:String = arrayFields[2]
            let goingIP:String = arrayFields[4]
            
            let caracter:CharacterSet = CharacterSet.init(charactersIn:":")
            
            var comIpArray:[String] = comingIP.components(separatedBy:".")
            let ipComing:String = comIpArray[0] + "." + comIpArray[1] + "." + comIpArray[2] + "." + comIpArray[3]
            let cip =  ipComing.trimmingCharacters(in:caracter)
            
            
            var goIpArray:[String] = goingIP.components(separatedBy:".")
            let ipGoing:String = goIpArray[0] + "." + goIpArray[1] + "." + goIpArray[2] + "." + goIpArray[3]
            let gip =  ipGoing.trimmingCharacters(in:caracter)
            
            if cip.characters.count < 17 {
                
                if ips.index(of:cip) == nil {
                   ips.append(cip)
                   fetchIpLocation(ipString:cip)
                }
            }
            
            if gip.characters.count < 17 {
                
                if ips.index(of:gip) == nil {
                   ips.append(gip)
                   fetchIpLocation(ipString:gip) //TODO: Poner entrante o saliente ???
                }
                
            }
            let url:URL = URL.init(fileURLWithPath:"/Users/kurushetra/Desktop/netstat2.txt")
            self.removeLinesFromFile(fileURL:url, numLines:1)
            print("------ line  processed and REMOVED -------")
            print(ips)
            
        }
        
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
    
    
    
    
    
//    func countLines(filePath:String) -> Int  {
//        
//        var resultNumber:Int!
//        
//        do {
//            let data:Data = try  Data(contentsOf:URL(fileURLWithPath:filePath))
//            let dataString:String = String(data:data, encoding:.utf8)!
//            let array = dataString.components(separatedBy:"\n")
//            
//            let lineContext:String = array[0]
//            
//            if lineContext == " " {
//                resultNumber = 0
//            } else {
//                resultNumber = array.count
//            }
//            
//        }catch {
//            resultNumber = 0
//        }
//        return resultNumber
//    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func fetchIpLocation(ipString:String) {
        
        let url = URL(string:"http://freegeoip.net/json/" + "\(ipString)")
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print(error ?? "Error in fetchIpLocation")
            }else{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                    
                    OperationQueue.main.addOperation({
                        //                        self.tableView.reloadData()
                        let managedContext = self.appDelegate.persistentContainer.viewContext
                        let entity = NSEntityDescription.entity(forEntityName: "IpAdress", in: managedContext)!
                        let ip = NSManagedObject(entity: entity,insertInto: managedContext) as! IpAdress
                        ip.city = json["city"] as? String
                        ip.number = ipString
                        
                        
                        
                        print(ip.city ?? "City no set")
                        
                        do {
                            try managedContext.save()
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
    
    
    
    
    
    
    
    
    
    
    
    
    
    func locateIp(number:String) {
        
    }
    
    func whoisIp(number:String) {
        
    }
    
    func nsLookupIp(number:String) {
        
    }
    
    
}

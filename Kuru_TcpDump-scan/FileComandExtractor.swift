//
//  FileComandExtractor.swift
//  Kuru_TcpDump-scan
//
//  Created by Kurushetra on 27/8/17.
//  Copyright © 2017 Kurushetra. All rights reserved.
//

//import Cocoa
import Foundation


//extension String {
//    
//    func matchingStrings(regex: String) -> [[String]] {
//        guard let regex = try? NSRegularExpression(pattern: regex, options: []) else { return [] }
//        let nsString = self as NSString
//        let results  = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
//        return results.map { result in
//            (0..<result.numberOfRanges).map { result.rangeAt($0).location != NSNotFound
//                ? nsString.substring(with: result.rangeAt($0))
//                : ""
//            }
//        }
//    }
//}




class FileComandExtractor  {
    
    
    //MARK: ---------------- FIREWALL State  -------------------------
    
    func extractBadHostsIps(ips:String) -> [String] {
       
        var results:[String] = []
        
        let ipsOk = ips.replacingOccurrences(of:" ", with:"")
        var lines:[String] = []
        lines = ipsOk.components(separatedBy:"\n")
        
        for  ip in  lines {
            if isIpNumber(ip:ip) {
                results.append(ip)
            }
        }
        return results
    }
    
    
    
     //MARK: ---------------- MTR_ROUTE  -------------------------
    
    func extractIpsFromMTRoute(ips:String) -> [TraceRouteNode] {
        
        var nodes:[TraceRouteNode] = []
        let ipsArray:[String] = ips.components(separatedBy:"\n")
        
        for ip in ipsArray {
            if isIpNumber(ip:ip) {
               nodes.append(TraceRouteNode(ip:ip))
            } else {
                print("ERROR: NO IP NUMBER...")
            }
            
        }
        return nodes
    }
    
    
    
    func isIpNumber(ip:String) -> Bool {
        
        var isIp:Bool = true
        let array:[String] = ip.components(separatedBy:".")
        
        if array.count == 4 {
            let number1  = Int(array[0])
            let number2  = Int(array[1])
            let number3  = Int(array[2])
            let number4  = Int(array[3])
            
            if number1 == nil || number2 == nil  || number3 == nil || number4 == nil {
                isIp = false
            }
        } else {
           isIp = false
        }
         return isIp
    }
    
    
    
    //MARK: ---------------- TRACE_ROUTE  -------------------------
    func extractTraceRoute(fileUrl:URL) -> [TraceRouteNode] {
        var fileLines:[String] = []
        var nodes:[TraceRouteNode] = []
        
        fileLines = extractLinesFrom(file:fileUrl)
        nodes =  extractIpsFromTraceRoute(lines:fileLines)
        
        return nodes
    }
    
    
    
    
    
    func extractIpsFromTraceRoute(lines:[String]) -> [TraceRouteNode] {
        
        var completIP:[[String]] = []
        var nodes:[TraceRouteNode] = []
        
        for  line in  lines {
            
            let  clean1 =  line.replacingOccurrences(of:" ", with:"/")
            
            var elementsCount = clean1.components(separatedBy:"//")
            
            for element in elementsCount {
                if element.contains("/ms") {
                    elementsCount.remove(at:elementsCount.index(of:element)!)
                }
                if element.characters.count <= 0 {
                    elementsCount.remove(at:elementsCount.index(of:element)!)
                }
                
            }
            
            if elementsCount.count == 2 {
                completIP.append(elementsCount)
            }
        }
        
        for ip in completIP {
            var  resultIp = ""
            var resultIps =  ""
            
            let number = ip[0].replacingOccurrences(of:"/", with: "")
            let element = ip[1].components(separatedBy:"/")
            
            if element.count == 3 { // trs values no puede ser
                 let ipTmp1 = element[2].replacingOccurrences(of:"(", with:"")
                   resultIp  = ipTmp1.replacingOccurrences(of:")", with:"")
                   resultIps = element[1]
                
            } else if element.count == 2 {
                
                let ipTmp1 = element[1].replacingOccurrences(of:"(", with:"")
                resultIp  = ipTmp1.replacingOccurrences(of:")", with:"")
                resultIps = element[0]

            }
            
            //let myString1 = "556"
            //let myInt1 = Int(myString1)
            
            
            if resultIp != "" { //FIXME: filtrar router
                
                
                let node:TraceRouteNode = TraceRouteNode(ip:resultIp)
//                node.ip = resultIp
                node.ips = resultIps
                node.number = number
                nodes.append(node)
            }
        }
         print(nodes)
        return nodes
    }
    
    
    
    
    
    
//    func extractIpsFromTraceRoute(lines:[String]) -> [String] {
//        
//        var arrayIps:[String] = []
//        
//        for  line in  lines {
//            //             print(line.matchingStrings(regex:"(\\d\\d?\\d?.\\d\\d?\\d?.\\d\\d?\\d?.\\d\\d?\\d?)"))
//            
//            if !line.contains("*") {
//                
//                var  ipsA:[String]
//                
//                ipsA  = line.matchingStrings(regex:"(\\d\\d?\\d?.\\d\\d?\\d?.\\d\\d?\\d?.\\d\\d?\\d?)")[0]
//                
//                //                 arrayIps.append(ipsA[0])
//                
//                if ipsA[0].contains("-") {
//                    ipsA  = line.matchingStrings(regex:"(\\d\\d?\\d?.\\d\\d?\\d?.\\d\\d?\\d?.\\d\\d?\\d?)")[1]
//                }
//                
//                arrayIps.append(ipsA[0])
//                //                 print("---------------------------------------------------------------")
//                
//                //                 print("---------------------------------------------------------------")
//                
//                
//                
//            }
//        }
//        //        print(arrayIps)
//        //        var array:[String] = [ipsA[0]]
//        var uniqueIps = uniqueElementsFrom(array:arrayIps)
//        
//        //                let uniqueUnordered = Array(Set(array))
//        print(uniqueIps)
//        
//        
//        return arrayIps
//    }
//    
//    
//    
//    
//    
//    func uniqueElementsFrom(array: [String]) -> [String] {
//        //Create an empty Set to track unique items
//        var set = Set<String>()
//        let result = array.filter {
//            guard !set.contains($0) else {
//                //If the set already contains this object, return false
//                //so we skip it
//                return false
//            }
//            //Add this item to the set since it will now be in the array
//            set.insert($0)
//            //Return true so that filtered array will contain this item.
//            return true
//        }
//        return result
//    }
//    
//    
    
    //MARK: ---------------- LINES EXTRACTOR  -------------------------
    func extractLinesFrom(file:URL) -> [String] {
        
        var arrayLines:[String] = ["No data"]
        var  data:Data!
        
        do   {
            data = try  Data(contentsOf:file)
            let dataString:String = String(data:data, encoding:.utf8)!
            arrayLines = dataString.components(separatedBy:"\n")
            
            if arrayLines.count >= 1 { //FIXME: Cambiar ha ??
                return arrayLines
            }else {
                arrayLines[0] = "No data"
                return arrayLines
            }
            
        }catch {
            print("no hay data")
        }
        
        return arrayLines
    }
    
    
    
   //MARK: ---------------- MTRoute EXTRACTOR  -------------------------
    
    func extractMTRoute(data:String) {
        
        let arr:[String] = data.components(separatedBy:"\n")
        
        for ip in arr {
            if ip != "???" {
                
            }
        }
        
    }
    
    
    
    
    
    
}

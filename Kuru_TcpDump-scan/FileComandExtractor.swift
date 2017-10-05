//
//  FileComandExtractor.swift
//  AppController-scan
//
//  Created by Kurushetra on 27/8/17.
//  Copyright © 2017 Kurushetra. All rights reserved.
//

//import Cocoa
import Foundation


 

class FileComandExtractor  {
    
    
    //MARK: ---------------- FIREWALL State  -------------------------
    
    func extractBadHostsIps(ips:String) -> [String] {
       
        var results:[String] = []
        
        let ipsOk = ips.replacingOccurrences(of:" ", with:"")
        var lines:[String] = []
        lines = ipsOk.components(separatedBy:"\n")
        
        for  ip in  lines {
            if isValid(ip:ip) {
                results.append(ip)
            }
        }
        return results
    }
    
  
    
    func isValid(ip: String) -> Bool {
        let parts = ip.components(separatedBy:".")
        let numbers = parts.flatMap { Int($0) }
        return parts.count == 4 && numbers.count == 4 && !numbers.contains {$0 < 0 || $0 > 255}
    }
    
  
    
    func findIpsIn(text:String) -> [String]! {
        
        let ips = findIP(inText:text)
        
        if ips.count >= 1 {
           return ips
        }else {
          return nil
        }
    }
    
    
   
    
    
    func findIP(inText:String) -> [String] {
        
//        let text = ".ip:9 (192.168.1.1) > 192.168.1.2 "
        let text2 = inText.replacingOccurrences(of:" ", with:"")
        var arrayNumbers:[String] = []
        
        
        //       var numeros =  text2.filter { char in
        //             let number = Int(char.description)
        //
        //            return (number != nil)
        //        }
        //
        var text3:String = ""
        
        
        for cha in text2 {
            
            let number = Int(cha.description)
            
            if number != nil {
                
                text3.append(cha)
            }else  if cha == "." {
                text3.append(cha)
            }else   {
                text3.append("-")
            }
        }
        arrayNumbers = text3.components(separatedBy:"-")
        var arrayN:[String] = []
        
        for  num in  arrayNumbers.indices {
            if arrayNumbers[num].characters.count >= 7 {
                if isValid(ip:arrayNumbers[num]) {
                   arrayN.append(arrayNumbers[num])
                }
                
            }
            
        }
        return arrayN
    }
    
    
  
 
    
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

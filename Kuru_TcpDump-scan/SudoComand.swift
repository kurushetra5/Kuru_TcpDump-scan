//
//  SudoComand.swift
//  AppController-scan
//
//  Created by Kurushetra on 2/9/17.
//  Copyright © 2017 Kurushetra. All rights reserved.
//

import Foundation

class SudoComand  {
    
    
    
    var sudoTask = Process()
    var sudoDelegate:TraceRouteDelegate!
    let filesManager:FilesManager = FilesManager.shared
    
    
    var sudoOutFile:FileHandle!
    var sudoFileUrl:URL = URL(fileURLWithPath:"/Users/kurushetra/Desktop/sudo.txt")
    
    
    
    
    func sudoWith(comand:String) {
        
        filesManager.createFileAtPath(path:"/Users/kurushetra/Desktop/sudo.txt")
        sudoTask = Process()
        sudoTask.launchPath = "/bin/sh"
        sudoTask.arguments = ["-c","echo nomeacuerdo8737  | sudo -S  pfctl -sa"]
        sudoOutFile = FileHandle(forWritingAtPath:"/Users/kurushetra/Desktop/sudo.txt")
        sudoTask.standardOutput = sudoOutFile
        NotificationCenter.default.addObserver(self, selector:#selector(sudoFinish), name:Process.didTerminateNotification, object:nil)
        

        sudoTask.launch()
        
    }
    
    
     @objc func sudoFinish() {
        print("sudoTask finish")
        sudoTask.terminate()
        do   {
            let data = try  Data(contentsOf:sudoFileUrl)
            let _:String = String(data:data, encoding:.utf8)!
//            sudoDelegate.whoisFinish(result:dataString)
        }catch {
            print("ERROR: whois file not read it..")
        }
        
    }
    

}

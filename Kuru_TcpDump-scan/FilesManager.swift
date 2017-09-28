//
//  FilesManager.swift
//  AppController-scan
//
//  Created by Kurushetra on 28/8/17.
//  Copyright © 2017 Kurushetra. All rights reserved.
//

import Foundation



 final class FilesManager  {
    
    private init() { }
    static let shared = FilesManager()
    
    
    var traceRouteFileUrl:URL = URL(fileURLWithPath:"/Users/kurushetra/Desktop/traceRoute.txt")
    var tcpDumpFileUrl:URL = URL(fileURLWithPath:"/Users/kurushetra/Desktop/netstat2.txt")
    var saveDumpFileUrl:URL = URL(fileURLWithPath:"/Users/kurushetra/Desktop/saveDump.txt")
    
    
    var filemgr: FileManager!{
        return FileManager.default
    }

    
    //TODO: Guardar preferences plist.
    func setFilesPaths(tcpDumpFilePath:String,traceRouteFilePath:String,saveDumpFilePath:String) {
        tcpDumpFileUrl =  URL(fileURLWithPath:tcpDumpFilePath)
        traceRouteFileUrl = URL(fileURLWithPath:traceRouteFilePath)
        saveDumpFileUrl = URL(fileURLWithPath:saveDumpFilePath)

    }
    
    
    
    
    func writeToFile(fileToWrite:String, data:[String]) -> Int  {
        
        let newLine = "\n"
        var counter = 0
        
        let fileHandler:FileHandle = FileHandle(forWritingAtPath:fileToWrite)!
        
        for file in data {
            fileHandler.write(file.data(using:.utf8)!)
            fileHandler.write(newLine.data(using:.utf8)!)
            counter += 1
        }
        return counter
    }
    
    
    
    
    
    
    func countLines(fileURL:URL) -> Int  {
        
        var resultNumber:Int!
        
        do {
            let data:Data = try  Data(contentsOf:fileURL)
            let dataString:String = String(data:data, encoding:.utf8)!
            let array = dataString.components(separatedBy:"\n")
            
            resultNumber = array.count
        }catch {
            resultNumber = 0
        }
        return resultNumber
    }
    
    
    func createFileAtPath(path:String) {
        filemgr.createFile(atPath:path, contents:nil, attributes:nil)
    }
    
    
    func currentPath() -> String {
        var path:String!
        path =  filemgr.currentDirectoryPath
        print("Current directory is", path);
        return path
        
    }
    
    
    
    func changeToWorkingPath(newPath:String) {
        
        var path:String!
        
        if filemgr.changeCurrentDirectoryPath(newPath) == true {
            path =  filemgr.currentDirectoryPath
            print("Current directory is %@", path);
        } else {
            print("No changed...");
            
        }
    }
    


}

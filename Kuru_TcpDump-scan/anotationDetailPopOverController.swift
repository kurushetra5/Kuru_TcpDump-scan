//
//  anotationDetailPopOverController.swift
//  Kuru_TcpDump-scan
//
//  Created by Kurushetra on 30/8/17.
//  Copyright © 2017 Kurushetra. All rights reserved.
//

import Cocoa

class anotationDetailPopOverController: NSViewController , WhoisDelegate,LookUpDelegate {

    
    @IBOutlet weak var ipName: NSTextField!
    
    @IBOutlet var resultsComandText: NSTextView!
    
    @IBOutlet weak var nodeDetailInfoLabel: NSTextField!
    
    @IBAction func whois(_ sender: Any) {
        print("whois")
        comandsManager.whoisTo(ip:"188.68.56.162")
    }
    
    @IBAction func lookUp(_ sender: Any) {
        print("lookUp")
        comandsManager.nsLookupTo(ip:"188.68.56.162")
    }

    @IBAction func route(_ sender: Any) {
        print("route")
    }

    @IBAction func follow(_ sender: Any) {
        print("follow")
    }

    @IBAction func block(_ sender: Any) {
        print("block")
    }

    
    
    
    var comandsManager:Comands = Comands.shared
    var anotation:IpAnotation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        comandsManager.whoisDelegate = self
        comandsManager.nsLookupDelegate = self
        nodeDetailInfoLabel.stringValue = formatNodeInfo(anotation:anotation)
    }
    
    
    func formatNodeInfo(anotation:IpAnotation) -> String {
        
        let result:String = anotation.title! + "-" + anotation.subtitle!
//     let result:String = "\(anotation.title)   \(String(describing: ip.city))   \(String(describing: ip.country))   \(String(describing: ip.number))  \(ip.latitud)  + \(String(describing: ip.longitude))"
    
        return result
    }
    
    func whoisFinish(result:String) {
        resultsComandText.string = result
    }
    
    func lookUpFinish(result: String) {
        resultsComandText.string = result
    }
    
    
}

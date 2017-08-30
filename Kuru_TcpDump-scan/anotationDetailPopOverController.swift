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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        comandsManager.whoisDelegate = self
        comandsManager.nsLookupDelegate = self
    }
    
    
    
    func whoisFinish(result:String) {
        resultsComandText.string = result
    }
    
    func lookUpFinish(result: String) {
        resultsComandText.string = result
    }
    
    
}

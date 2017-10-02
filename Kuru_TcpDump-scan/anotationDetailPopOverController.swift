//
//  anotationDetailPopOverController.swift
//  AppController-scan
//
//  Created by Kurushetra on 30/8/17.
//  Copyright © 2017 Kurushetra. All rights reserved.
//

import Cocoa

class anotationDetailPopOverController: NSViewController   {

    
    @IBOutlet weak var ipName: NSTextField!
    
    @IBOutlet var resultsComandText: NSTextView!
    
    @IBOutlet weak var nodeDetailInfoLabel: NSTextField!
    
    @IBAction func whois(_ sender: Any) {
        print("whois")
//        comandsManager.whoisTo(ip:anotation.node.number!)
    }
    
    @IBAction func lookUp(_ sender: Any) {
        print("lookUp")
//        comandsManager.nsLookupTo(ip:anotation.node.number!)
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
//        comandsManager.whoisDelegate = self
//        comandsManager.nsLookupDelegate = self
//        nodeDetailInfoLabel.stringValue = formatNodeInfo(anotation:anotation)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        nodeDetailInfoLabel.stringValue = formatNodeInfo(anotation:anotation)
    }
    
    func formatNodeInfo(anotation:IpAnotation) -> String {
        
        let result:String = anotation.node.number! + " " + anotation.node.aso! + " " + anotation.node.country!
        return result
    }
    
    func whoisFinish(result:String) {
        resultsComandText.string = result
    }
    
    func lookUpFinish(result: String) {
        resultsComandText.string = result
    }
    
    
}

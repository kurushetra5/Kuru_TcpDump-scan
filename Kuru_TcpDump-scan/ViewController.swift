//
//  ViewController.swift
//  Kuru_TcpDump-scan
//
//  Created by Kurushetra on 20/8/17.
//  Copyright © 2017 Kurushetra. All rights reserved.
//

import Cocoa
import MapKit



class ViewController: NSViewController ,IPsDelegate,NSTableViewDataSource,NSTableViewDelegate{

    @IBOutlet weak var map: MKMapView!
    
    
    @IBOutlet weak var ipsTableView: NSTableView!
    
    
    @IBAction func StartTcpDumpScan(_ sender: Any) {
         tcpDump.startTcpScan()
        
    }
    
    @IBAction func StopTcpDumpScan(_ sender: Any) {
         tcpDump.terminateCommand()
    }
    
    
    
    
    let tcpDump = Kuru_TcpDump()
    var ipsToShow:[String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tcpDump.ipsDelegate = self
    }

    
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    
    func newIpComing(ips:[String]) {
         ipsToShow = ips
         ipsTableView.reloadData()
    }
    
    
    func numberOfRows(in tableView: NSTableView) -> Int {
         return ipsToShow?.count ?? 0
    }
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        
        
        let cell = tableView.make(withIdentifier: "ipsCell", owner: nil) as? NSTableCellView
        cell?.textField?.stringValue = ipsToShow[row]
        
        
        return cell

    }
    
}


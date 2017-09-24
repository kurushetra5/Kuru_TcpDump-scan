//
//  ViewController.swift
//  Kuru_TcpDump-scan
//
//  Created by Kurushetra on 20/8/17.
//  Copyright © 2017 Kurushetra. All rights reserved.
//

import Cocoa
import MapKit



class ViewController: NSViewController ,IPsDelegate,ProcessDelegate,ComandWorkingDelegate,NSTableViewDataSource,NSTableViewDelegate{

    @IBOutlet weak var map: MKMapView!
    
    
    @IBOutlet weak var ipsTableView: NSTableView!
    
    @IBOutlet weak var pathForTcpDumpFile: NSTextField!
    @IBOutlet weak var pathForTraceRouteFile: NSTextField!
    @IBOutlet weak var pathForSaveDumpFile: NSTextField!
    
    
    @IBOutlet weak var packagesCount: NSTextField!
    @IBOutlet weak var packagesProcessed: NSTextField!
    
    @IBOutlet weak var traceRouteIp: NSTextField!
    
    @IBOutlet weak var fireWallStateLabel: NSTextField!
    
    
    @IBOutlet var popOverController: anotationDetailPopOverController!
    
    @IBOutlet weak var comandsTableView: NSTableView!
    
    @IBOutlet weak var stateRuning: NSImageView!
    @IBOutlet weak var comandRuningLabel: NSTextField!
    
    
    @IBAction func StartTcpDumpScan(_ sender: Any) {
         tcpDump.startTcpScan()
    }
    
    @IBAction func StopTcpDumpScan(_ sender: Any) {
         tcpDump.terminateCommand()
    }
   
    
    @IBAction func freeScan(_ sender: Any) {
         tcpDump.dataBaseModeOff()
    }
    
    @IBAction func traceRoute(_ sender: Any) {
        renderedNodes = []
        tcpDump.traceRouteTo(ip:traceRouteIp.stringValue)
//        61.232.254.39
    }
    
    
    @IBAction func killConection(_ sender: NSButton) {
        
    }
    
    
    @IBAction func netStat(_ sender: NSButton) {
        tcpDump.comandsManager.runProcessWith(comand:tcpDump.comandsManager.netStatComand, args:tcpDump.comandsManager.netStatArgs,delegate: self)
    }
    
    
    @IBAction func whois(_ sender: NSButton) {
        tcpDump.comandsManager.whoisTo(ip:traceRouteIp.stringValue)
    }
    
    
    
    @IBAction func nsLookUp(_ sender: NSButton) {
        tcpDump.comandsManager.nsLookupTo(ip:traceRouteIp.stringValue)
    }
    
    
    @IBAction func mtRoute(_ sender: NSButton) {
        
        if isIpSelected() {
         tcpDump.comandsManager.runComand(type:ComandType.mtRoute, ip:traceRouteIp.stringValue, delegate:self)
        }
        //tcpDump.comandsManager.runProcessWith(comand:tcpDump.comandsManager.mtrRouteComand , args:tcpDump.comandsManager.mtrRouteArgs ,delegate: self)
    }
    
    
    
    @IBAction func startFireWall(_ sender: NSButton) {
        
    }
    
    
    
    @IBAction func setPathSettingsChanges(_ sender: Any) {
        filesManager.setFilesPaths(tcpDumpFilePath:pathForTcpDumpFile.stringValue, traceRouteFilePath: pathForTraceRouteFile.stringValue, saveDumpFilePath: pathForSaveDumpFile.stringValue)
        configureView()
    }
    
    
    
    @IBAction func checkPacages(_ sender:NSButton) {
       tcpDump.countPackages(mode:sender.state.rawValue)
    }
    
    @IBAction func checkProcessed(_ sender: NSButton) {
        tcpDump.countProcessed(mode:sender.state.rawValue)
    }
    
    @IBAction func cleanDataBase(_ sender: Any) {
        tcpDump.cleanDataBase()
    }
    
    @IBAction func cleanTcpDumpFile(_ sender: Any) {
        filesManager.createFileAtPath(path:filesManager.tcpDumpFileUrl.relativePath)
    }
    
    @IBAction func filterIpsInTcpDumpCommand(_ sender: NSButton) {
        tcpDump.filterInTcpDumpCommand = FilterInTcpDumpCommand(rawValue:sender.state.rawValue)!
    }
    
    @IBAction func showIpsDataBase(_ sender: Any) {
       tcpDump.tcpDumpComand.getIps()
    }
    
    
    
    func executeSudoComand() {
        let sudo:SudoComand = SudoComand()
        sudo.sudoWith(comand:"")
    }
    
    
    
    func procesFinishWith(nodes:[TraceRouteNode]) {
        comandToShow.append(nodes[0])
        comandsTableView.reloadData()
    }
    
    
    func newDataFromProcess(data:String , processName:String) { //FIXME: quitar delegado
//        let arrayData:[String] = data.components(separatedBy:"\n")
//         print(arrayData)
    }
    
    
    func alert(error: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.icon =  NSImage.init(named:.network)
        alert.messageText = error
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        return alert.runModal() == .alertFirstButtonReturn
    }
    
  
    
    func isIpSelected() -> Bool {
        
        if traceRouteIp.stringValue.isEmpty {
            print("IP no selected")
          _ =  alert(error: "No hay ninguna IP seleccionada", text: "Selecciona una")
           return false //TODO: Alerta
        }else {
            return true
        }
    }
    
    
    
    
    //MARK:------------------ MAP_VIEW ACTIONS -----------------
    
    @IBAction func showNodesInMap(_ sender: NSButton) {
//         executeSudoComand()
        if sender.state.rawValue == 0 {
            tcpDump.showNodesInMapView = NotesInMapMode.off
           mapEngine.mapView.removeAnnotations(mapEngine.mapView.annotations)
        } else {
        tcpDump.showNodesInMap(mode:NotesInMapMode(rawValue: sender.state.rawValue)!)
        }
    }
    
   
    
    fileprivate enum CellIdentifiers {
        static let NumberCell = "NumberCell"
        static let CountryCell = "CountryCell"
        static let StateCell = "StateCell"
        static let CityCell = "CityCell"
        static let LatitudCell = "LatitudCell"
        static let LongitudeCell = "LongitudeCell"
        
    }
    
    
    var mapEngine:MapRouteEngine!
    let filesManager:FilesManager = FilesManager.shared
    let tcpDump = Kuru_TcpDump()
    var ipsToShow:[Node]?
    var comandToShow:[TraceRouteNode] = []
    var oldNode:Node!
    var renderedNodes:[Node] = []
    var traceRouteNodesCount:Int = 1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        tcpDump.ipsDelegate = self
        mapEngine = MapRouteEngine(withMap:map)
        mapEngine.popOverController = popOverController
        mapEngine.startEngine()
        
    }

    
    func configureView() {
        
        pathForTcpDumpFile.stringValue =  filesManager.tcpDumpFileUrl.absoluteString
        pathForTraceRouteFile.stringValue =  filesManager.traceRouteFileUrl.absoluteString
        pathForSaveDumpFile.stringValue = filesManager.saveDumpFileUrl.absoluteString
        comandRuningLabel.stringValue =  ""
        stateRuning.alphaValue = 0.5
    }
    
    
    func commandIsWorking(comandType:ComandType) {
        animateComandWork()
        comandRuningLabel.stringValue = comandType.rawValue
    }
    
    func animateComandWork() {
        
        if stateRuning.animator().alphaValue == 1 {
            NSAnimationContext.current.duration = 0.4
            stateRuning.animator().alphaValue = 0
        } else {
            NSAnimationContext.current.duration = 0.4
            stateRuning.animator().alphaValue = 1
        }
    }
    
    
  
    
    
    func updatePackagesCounts() {
        
      packagesCount.integerValue = filesManager.countLines(fileURL:filesManager.tcpDumpFileUrl)
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    func newPackage() {
        updatePackagesCounts()
    }
    
    func packageProcessed(number:Int) {
        packagesProcessed.integerValue = number
    }
    
    
    
    func newNode(node:Node) {
        
        for  aNode in renderedNodes {
            if aNode.isEqualTo(node:node) {
               return
            }
        }
        
        renderedNodes.append(node)
        
        var nodeAnotation:IpAnotation = IpAnotation()
        nodeAnotation  = node.nodeAnotation()
//        nodeAnotation.subtitle = String(traceRouteNodesCount)
//        nodeAnotation.coordinate.latitude = node.latitud
//        nodeAnotation.coordinate.longitude = node.longitude
//        nodeAnotation.node = node
        mapEngine.addIp(anotation:nodeAnotation)
        
        
        traceRouteNodesCount += 1
        print(traceRouteNodesCount)
       let locationA:CLLocation!
        
        if oldNode == nil {
           mapEngine.currentLocation =  CLLocation(latitude:41.1754, longitude:1.2697)
           locationA  = mapEngine.currentLocation
          oldNode = node
        }else {
             locationA  = CLLocation(latitude:oldNode.latitud, longitude:oldNode.longitude)
        }
        
        let locationB:CLLocation = CLLocation(latitude:node.latitud, longitude:node.longitude)
        mapEngine.drawHaLine(locationA:locationA ,locationB:locationB)
         oldNode = node
    }
    
    
    func showAnotationsInMap(anotations:[IpAnotation]) {
        mapEngine.mapView.addAnnotations(anotations)
    }
    
    
    func newIpComing(ips:[Node]) {
         ipsToShow = ips
         ipsTableView.reloadData()
    }
    
    
    
    
    
    func newConection(ip:Node) {
        
         mapEngine.addIp(anotation:ip.anotation)
                mapEngine.currentLocation =  CLLocation(latitude:41.1754, longitude:1.2697)
        //        let locationA:CLLocation = CLLocation(latitude:ipsToShow![0].latitud, longitude:Double(ipsToShow![0].longitude!)!)
                 let locationB:CLLocation = CLLocation(latitude:(ip.latitud), longitude: ip.longitude)
                mapEngine.drawHaLine(locationA:mapEngine.currentLocation ,locationB:locationB)

    }
    
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        if tableView.identifier!.rawValue == "comands" {
            return comandToShow.count
        }
         return ipsToShow?.count ?? 0
    }
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if tableView.identifier!.rawValue == "comands" {
             let comands:TraceRouteNode = comandToShow[row]
            var text: String = "-"
            var cellIdentifier: String = ""
            
            if tableColumn == comandsTableView.tableColumns[0] {
                cellIdentifier = "NumberCell"
                text = comands.ip ?? "-error-"
            } else if tableColumn == comandsTableView.tableColumns[1] {
                cellIdentifier = "CountryCell"
                text = comands.country ?? "-"
            }
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView
            cell?.textField?.stringValue = text
            return cell
        }
        
        
        
        
        
        guard let ipToShow:Node = ipsToShow?[row]  else {
            return nil
        }
        
        
        
//        var image: NSImage?
        var text: String = "-"
        var cellIdentifier: String = ""
        
        if tableColumn == ipsTableView.tableColumns[0] {
            cellIdentifier = CellIdentifiers.NumberCell
            text = ipToShow.number ?? "-error-"
        } else if tableColumn == ipsTableView.tableColumns[1] {
            cellIdentifier = CellIdentifiers.CountryCell
            text = ipToShow.country ?? "-"
        }else if tableColumn == ipsTableView.tableColumns[2] {
            cellIdentifier = CellIdentifiers.StateCell
            text = ipToShow.aso ?? "-"
        }
        else if tableColumn == ipsTableView.tableColumns[3] {
            cellIdentifier = CellIdentifiers.CityCell
            text = ipToShow.city ?? "-"
        }

        else if tableColumn == ipsTableView.tableColumns[4] {
            cellIdentifier = CellIdentifiers.LatitudCell
            text =  String(ipToShow.latitud)
        }
        else if tableColumn == ipsTableView.tableColumns[5] {
            cellIdentifier = CellIdentifiers.LongitudeCell
            text = String(ipToShow.longitude)
        }
        
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView
        cell?.textField?.stringValue = text
        
        
        

        
        return cell

    }
    
    
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        if comandsTableView.selectedRow >= 0 {
            let ipSelected:TraceRouteNode = comandToShow[comandsTableView.selectedRow]
            traceRouteIp.stringValue = ipSelected.ip!
        }
        
        
        if ipsTableView.selectedRow >= 0 {
            
            let ipSelected:Node = ipsToShow![ipsTableView.selectedRow]
            traceRouteIp.stringValue = ipSelected.number!
            
            mapEngine.focusNewIPInView(location:CLLocation(latitude:ipSelected.latitud, longitude:Double(ipSelected.longitude)))
        }
        
        
        
    }
    
}


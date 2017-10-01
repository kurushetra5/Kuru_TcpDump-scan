//
//  ViewController.swift
//  AppController-scan
//
//  Created by Kurushetra on 20/8/17.
//  Copyright © 2017 Kurushetra. All rights reserved.
//

import Cocoa
import MapKit


class ViewController: NSViewController ,IPsDelegate,ProcessDelegate,ComandWorkingDelegate,NSTableViewDataSource,NSTableViewDelegate ,NSTabViewDelegate{
    
    
    //MARK:--------------------------------------- OUTLETS ---------------------------------------
    
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
    @IBOutlet weak var fireWallTableView: NSTableView!
    @IBOutlet weak var stateRuning: NSImageView!
    @IBOutlet weak var comandRuningLabel: NSTextField!
    @IBOutlet weak var blockIpText: NSTextField!
    @IBOutlet weak var fireWallStartStop: NSButton!
    @IBOutlet weak var blockIpButton: NSButton!
    @IBOutlet weak var unBlockIpButton: NSButton!
    
    
    //MARK:--------------------------------------- ACTIONS ---------------------------------------
    
    @IBAction func StartTcpDumpScan(_ sender: Any) {
        appController.startTcpScan()
    }
    @IBAction func StopTcpDumpScan(_ sender: Any) {
        appController.terminateCommand()
    }
    @IBAction func freeScan(_ sender: Any) {
        appController.dataBaseModeOff()
    }
    @IBAction func traceRoute(_ sender: Any) {
        renderedNodes = []
        appController.traceRouteTo(ip:traceRouteIp.stringValue)
        //        61.232.254.39
    }
    @IBAction func killConection(_ sender: NSButton) {
        
    }
    @IBAction func netStat(_ sender: NSButton) {
        appController.comandsManager.runProcessWith(comand:appController.comandsManager.netStatComand, args:appController.comandsManager.netStatArgs,delegate: self)
    }
    @IBAction func whois(_ sender: NSButton) {
        appController.comandsManager.whoisTo(ip:traceRouteIp.stringValue)
    }
    @IBAction func nsLookUp(_ sender: NSButton) {
        appController.comandsManager.nsLookupTo(ip:traceRouteIp.stringValue)
    }
    @IBAction func mtRoute(_ sender: NSButton) {
        
        if isIpSelected() {
            appController.comandsManager.runComand(type:ComandType.mtRoute, ip:traceRouteIp.stringValue, delegate:self)
        }
        //tcpDump.comandsManager.runProcessWith(comand:tcpDump.comandsManager.mtrRouteComand , args:tcpDump.comandsManager.mtrRouteArgs ,delegate: self)
    }
    @IBAction func startFireWall(_ sender: NSButton) {
        
        if sender.state == .on {
            appController.comandsManager.runComand(type:ComandType.fireWallStart, ip:nil, delegate:self)
        }else {
            appController.comandsManager.runComand(type:ComandType.fireWallStop, ip:nil, delegate:self)
        }
    }
    @IBAction func setPathSettingsChanges(_ sender: Any) {
        filesManager.setFilesPaths(tcpDumpFilePath:pathForTcpDumpFile.stringValue, traceRouteFilePath: pathForTraceRouteFile.stringValue, saveDumpFilePath: pathForSaveDumpFile.stringValue)
        configureView()
    }
    @IBAction func checkPacages(_ sender:NSButton) {
        appController.countPackages(mode:sender.state.rawValue)
    }
    @IBAction func checkProcessed(_ sender: NSButton) {
        appController.countProcessed(mode:sender.state.rawValue)
    }
    @IBAction func cleanDataBase(_ sender: Any) {
        appController.cleanDataBase()
    }
    @IBAction func cleanTcpDumpFile(_ sender: Any) {
        filesManager.createFileAtPath(path:filesManager.tcpDumpFileUrl.relativePath)
    }
    @IBAction func filterIpsInTcpDumpCommand(_ sender: NSButton) {
        appController.filterInTcpDumpCommand = FilterInTcpDumpCommand(rawValue:sender.state.rawValue)!
    }
    @IBAction func showIpsDataBase(_ sender: Any) {
        ipsToShow =  appController.dataBase.dataBase
         ipsTableView.reloadData()
    }
    @IBAction func blockIp(_ sender: Any) {
        nodeSelectedForFireWall()
        appController.comandsManager.runComand(type:ComandType.addFireWallBadHosts, node:selectedNode, delegate:self)
        
    }
    @IBAction func unBlockIp(_ sender: Any) {
        nodeSelectedForFireWall()
        appController.comandsManager.runComand(type:ComandType.deleteFireWallBadHosts, node:selectedNode, delegate:self)
    }
    @IBAction func showNodesInMap(_ sender: NSButton) {
        
        if sender.state.rawValue == 0 {
            appController.showNodesInMapView = NotesInMapMode.off
            mapEngine.mapView.removeAnnotations(mapEngine.mapView.annotations)
        } else {
            appController.showNodesInMap(mode:NotesInMapMode(rawValue: sender.state.rawValue)!)
        }
    }
    
    
    
    
    
    
    
    
    //MARK:--------------------------------------- VARS ---------------------------------------
    
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
    let appController = AppController()
    var ipsToShow:[Node] = []
//    var comandToShow:[TraceRouteNode] = []
    var comandsToShow:[Node] = []
    var oldNode:Node!
    var renderedNodes:[Node] = []
    var traceRouteNodesCount:Int = 1
    var selectedIp:String!
    var blockedIps:[String] = []
    var blockedNodes:[Node] = []
//    var blockedFireWallNodes:[TraceRouteNode] = []
    var selectedNode:Node!
//    var selectedTraceRouteNode:TraceRouteNode!
    
    
    
    
    //MARK:--------------------------------------- FUNC ---------------------------------------
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        appController.ipsDelegate = self
        mapEngine = MapRouteEngine(withMap:map)
        mapEngine.popOverController = popOverController
        mapEngine.startEngine()
         
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
   
    func configureView() {
        pathForTcpDumpFile.stringValue =  filesManager.tcpDumpFileUrl.absoluteString
        pathForTraceRouteFile.stringValue =  filesManager.traceRouteFileUrl.absoluteString
        pathForSaveDumpFile.stringValue = filesManager.saveDumpFileUrl.absoluteString
        comandRuningLabel.stringValue =  ""
        stateRuning.alphaValue = 0.5
    }
    
    
    
    func nodeSelectedForFireWall()  {
        
        for node  in  ipsToShow {
            if node.number == blockIpText.stringValue {
                selectedNode = node
            }
        }
    }
    
    
    
    func executeSudoComand() {
        let sudo:SudoComand = SudoComand()
        sudo.sudoWith(comand:"")
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
        
        if selectedNode == nil {
            print("IP no selected")
            _ =  alert(error: "No hay ninguna IP seleccionada", text: "Selecciona una")
            return false
        }else {
            return true
        }
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
        
//        print(traceRouteNodesCount)
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
       let locationB:CLLocation = CLLocation(latitude:(ip.latitud), longitude: ip.longitude)
        mapEngine.drawHaLine(locationA:mapEngine.currentLocation ,locationB:locationB)
    }
    
    
    
    
    //MARK:--------------------------------------- COMANDS delegates ---------------------------------------
    func procesFinishWith(node:Node, processName:String) {
        
        switch processName {
        case ComandType.fireWallBadHosts.rawValue:
             blockedNodes.append(node)
             fireWallTableView.reloadData()
            
        default:
            print("Error:procesFinishWith(node:Node, processName:String, amountNodes:Int) ")
        }
    }
    
    
    func procesFinishWith(node:Node) {
        ipsToShow.append(node)
        comandsTableView.reloadData()
    }
    
    
    func procesFinishWith(node:Node, processName:String, amountNodes:Int) {
        switch processName {
        case ComandType.fireWallBadHosts.rawValue:
            blockedNodes.append(node)
            
            if amountNodes == blockedNodes.count {
                fireWallTableView.reloadData()
            }
        case ComandType.mtRoute.rawValue:
            comandsToShow.append(node)
            comandsTableView.reloadData()
             print("MTRoute")
        default:
            print("Error:procesFinishWith(node:Node, processName:String, amountNodes:Int) ")
        }
    }
    
    
    
    func procesFinishWith(node:TraceRouteNode, processName:String, amountNodes:Int) {
        
//        switch processName {
//        case ComandType.fireWallBadHosts.rawValue:
//             blockedFireWallNodes.append(node)
//
//            if amountNodes == blockedFireWallNodes.count {
//                fireWallTableView.reloadData()
//            }
//
//        default:
//            print("Error: procesFinishWith(node:TraceRouteNode, processName:String, amountNodes:Int) ")
//        }
    }
    
    
    
    func procesFinishWith(nodes:[TraceRouteNode]) {
//        comandToShow.append(nodes[0])
//        comandsTableView.reloadData()
    }
    
    
    func procesFinish(processName:String) {
        switch processName {
        case ComandType.fireWallStart.rawValue:
            appController.comandsManager.runComand(type:ComandType.fireWallState, ip:nil, delegate:self)
            
        case ComandType.fireWallStop.rawValue:
            appController.comandsManager.runComand(type:ComandType.fireWallState, ip:nil, delegate:self)
            
        case ComandType.addFireWallBadHosts.rawValue:
            blockedNodes = []
            updateBadHostsTableView()
            
        case ComandType.deleteFireWallBadHosts.rawValue:
            blockedNodes = []
            updateBadHostsTableView()
        default:
            print("Error: procesFinish(processName:String)")
        }
    }
    
    
    
    
    
    func newDataFromProcess(data:String , processName:String) {
        
        switch processName {
        case ComandType.fireWallState.rawValue:
            fireWallStateLabel.stringValue = data
            if data.contains("Enabled") {
                fireWallStartStop.title = "Stop"
                fireWallStartStop.state = .on
            }else {
                fireWallStartStop.title = "Start"
                fireWallStartStop.state = .off
            }
            updateBadHostsTableView()
            
        case ComandType.fireWallBadHosts.rawValue:
//            blockedNodes = []
            fireWallTableView.reloadData()
        default:
            print("Error: newDataFromProcess(data:String , processName:String)")
        }
        
    }
    
    
    func updateBadHostsTableView() {
        appController.comandsManager.runComand(type:ComandType.fireWallBadHosts,ip:nil, delegate:self)
    }
    
    
    
    
    //MARK:--------------------------------------- TABLE_VIEW Delegate ---------------------------------------
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        if tableView.identifier!.rawValue == "comands" {
            return comandsToShow.count
        }
        if tableView.identifier!.rawValue == "fireWall" {
            return blockedNodes.count
        }
        return ipsToShow.count
    }
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if tableView.identifier!.rawValue == "fireWall" {
            
//            let ip:TraceRouteNode = blockedFireWallNodes[row]
            let ip: Node = blockedNodes[row]
            var text: String = "-"
            var cellIdentifier: String = ""
            
            if tableColumn == fireWallTableView.tableColumns[0] {
                cellIdentifier = "IpBlocked"
                text = ip.number!
            }
            if tableColumn == fireWallTableView.tableColumns[1] {
                cellIdentifier = "country"
                text = ip.country!
            }
            if tableColumn == fireWallTableView.tableColumns[2] {
                cellIdentifier = "date"
                text = "date"
            }
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView
            cell?.textField?.stringValue = text
            return cell
        }
        
        
        if tableView.identifier!.rawValue == "comands" {
            let comands:Node = comandsToShow[row]
            var text: String = "-"
            var cellIdentifier: String = ""
            
            if tableColumn == comandsTableView.tableColumns[0] {
                cellIdentifier = "NumberCell"
                text = comands.number!
            } else if tableColumn == comandsTableView.tableColumns[1] {
                cellIdentifier = "CountryCell"
                text = comands.country ?? "-"
            }
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView
            cell?.textField?.stringValue = text
            return cell
        }
        
        let ipToShow:Node = ipsToShow[row]
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
            let ipSelected:Node = comandsToShow[comandsTableView.selectedRow]
            traceRouteIp.stringValue = ipSelected.number!
            selectedIp = ipSelected.number!
            //              return
        }
        
        if fireWallTableView.selectedRow >= 0 {
            let ipSelected2:Node = blockedNodes[fireWallTableView.selectedRow]
            blockIpText.stringValue = ipSelected2.number!
            containsIP(ip:ipSelected2.number!)
            
//            let ipSelected:TraceRouteNode = blockedFireWallNodes[fireWallTableView.selectedRow]
//            blockIpText.stringValue = ipSelected.ip!//TODO: arreglar esto node traceroutenode
            fireWallTableView.deselectAll(nil)
            
//             containsIP(ip:ipSelected.ip!)
            return
            
        }
        
        
        if ipsTableView.selectedRow >= 0 {
            
            let ipSelected:Node = ipsToShow[ipsTableView.selectedRow]
            selectedIp = ipSelected.number!
            selectedNode = ipSelected
            ipsTableView.deselectAll(nil)
            traceRouteIp.stringValue = ipSelected.number!
            blockIpText.stringValue = ipSelected.number!
            containsIP(ip:ipSelected.number!)
            
 
            mapEngine.focusNewIPInView(location:CLLocation(latitude:ipSelected.latitud, longitude:Double(ipSelected.longitude)))
         return
        }
        
        
        
    }
    
    
    
    func containsIP(ip:String)  {
        
       for node in blockedNodes {
            if node.number! ==  ip {
                blockIpButton.isEnabled = false
                unBlockIpButton.isEnabled = true
                return
            }else {
                blockIpButton.isEnabled = true
                unBlockIpButton.isEnabled = false
            }
        }
     
    }
    
    
    
    
    //MARK:--------------------------------------- TAB_VIEW Delegate ---------------------------------------
    func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        
        if tabView.selectedTabViewItem?.identifier! as! String == "fireWall" {
            print("Si")
            blockedNodes = []
            fireWallTableView.reloadData()
            appController.comandsManager.runComand(type:ComandType.fireWallState, ip:nil, delegate:self)
            
        } else {
            print("No")
        }
        
        
    }
}


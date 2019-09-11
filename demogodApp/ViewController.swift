//
//  ViewController.swift
//
//

import Cocoa

extension String: Differentiable {}

class ViewController: NSViewController {
    
    //MARK:- Public API
    //MARK:
    func requestToStart(withCommands cmds:[String] = []) {
        log = "\(#function) \(cmds)"
        processRun(withCommands: cmds)
    }
    
    func requestToStop() {
        log = "\(#function)"
        processStop()
    }
    
    func requestToSend(cmd val: String) {
        log = "\(#function) \(val)"
        processSend(stringValue: val)
    }
    
    //MARK:- Private Properties
    //MARK:
    @IBOutlet weak var tableView: NSTableView?
    fileprivate var tableViewDataStore: [String] = [] {
        didSet {
            let changeset = StagedChangeset(source: oldValue, target: tableViewDataStore)
            tableView?.reload(using: changeset, with: .effectFade) { (_) in }
        }
    }
    
    // Will be Blocking when running process
    fileprivate let processQueue = DispatchQueue(label: "com.downloadthebear.ViewController.processQueue")
    fileprivate let workQueue = DispatchQueue(label: "com.downloadthebear.ViewController.workQueue")

    fileprivate var log: String = "" {
        didSet {
            let localValue = log
            DispatchQueue.main.async { [weak self] in
//                print(localValue)
                guard let strongSelf = self else { return }
                let trunkString = String(localValue.prefix(65536))
                strongSelf.tableViewDataStore.append(trunkString)
            }
        }
    }
    
    fileprivate lazy var binaryURL: URL = {
        let mainBundle = Bundle.main.bundleURL
            .appendingPathComponent("Contents/Resources", isDirectory: true)
            .appendingPathComponent("demogod")
        return mainBundle
    }()
    
    fileprivate var process: Process? = nil

    //MARK:- Life Cycle
    //MARK:
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


    //MARK:- Private Functions
    //MARK:
    fileprivate func processRun(withCommands cmds:[String]) {
        self.processQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            if strongSelf.process != nil {
                strongSelf.log = "Error: process is already running!"
                return }

            let proc = Process()
            let binUrl = strongSelf.binaryURL
            proc.executableURL = binUrl
            strongSelf.process = proc
            
            strongSelf.attachToPipes(forProcess: proc)
            try? proc.run()
            
            cmds.forEach({ strongSelf.processSend(stringValue: $0) })
            proc.terminationHandler = {[weak self] (proc) in
                guard let strongSelf = self else { return }
                strongSelf.process = nil
            }
        }
    }
    
    fileprivate func processStop() {
        self.workQueue.async { [weak self] in
            guard let strongSelf = self,
                let proc = strongSelf.process else { return }
            strongSelf.sendEOF(toProcess: proc)
        }
    }
    
    fileprivate func processSend(stringValue value: String) {
        self.workQueue.async { [weak self] in
            guard let strongSelf = self,
                let proc = strongSelf.process else { return }
            strongSelf.sendString(toProcess: proc, value)
        }
    }
    
    fileprivate func attachToPipes(forProcess proc: Process) {
        
        let stdInPipe = Pipe()
        let stdOutPipe = Pipe()
        let stdErrPipe = Pipe()
        
        proc.standardInput = stdInPipe
        proc.standardOutput = stdOutPipe
        proc.standardError = stdErrPipe
        
        guard let stdOut = proc.standardOutput as? Pipe,
            let stdErr = proc.standardError as? Pipe else {
                log = "Error: No stderr or stdout"
                return
        }
            
        stdOut.fileHandleForReading.readabilityHandler = { [weak self] (fh :FileHandle) in
            guard let strongSelf = self,
                let output = String(data: fh.availableData, encoding: .utf8) else {
                    return
            }
            strongSelf.log = output
        }
        
        stdErr.fileHandleForReading.readabilityHandler = { [weak self] (fh :FileHandle) in
            guard let strongSelf = self,
                let output = String(data: fh.availableData, encoding: .utf8) else {
                    return
            }
            strongSelf.log = output
        } 
    }
    
    fileprivate func sendEOF(toProcess proc: Process) {
        guard let stdIn = proc.standardInput as? Pipe else {
            log = "Error: sendEOF but no standard in"
            return }
        stdIn.fileHandleForWriting.closeFile()
    }
    
    fileprivate func sendString(toProcess proc: Process,_ value: String) {
        guard let stdIn = proc.standardInput as? Pipe,
            let data = value.data(using: .utf8) else {
                log = "Error: sendString but no standard in or data is not in utf8 format"
                return }
        stdIn.fileHandleForWriting.write(data)
    }
    
}


extension ViewController: NSTableViewDelegate, NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return tableViewDataStore.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let datum = tableViewDataStore[row]
        if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "logcolumn") {
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "loginfo")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.stringValue = datum
            return cellView
        }
        return nil
    }
    
}

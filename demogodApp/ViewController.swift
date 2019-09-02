//
//  ViewController.swift
//  demogodApp
//
//

import Cocoa

class ViewController: NSViewController {
    
    //MARK:- Public API
    //MARK:
    func requestToStart() {
        log = "\(#file):\(#line) \(#function)"
        processRun()
    }
    
    func requestToStop() {
        log = "\(#file):\(#line) \(#function)"
        processStop()
    }
    
    func requestToSend(Value val: String) {
        log = "\(#file):\(#line) \(#function) \(val)"
        processSend(stringValue: val)
    }
    
    //MARK:- Private Properties
    //MARK:
    @IBOutlet weak var logview: NSScrollView?
    
    // Will be Blocking when running process
    fileprivate let processQueue = DispatchQueue(label: "com.downloadthebear.ViewController.processQueue")
    
    fileprivate let workQueue = DispatchQueue(label: "com.downloadthebear.ViewController.workQueue")

    fileprivate var log: String = "" {
        didSet {
            let localValue = log
            DispatchQueue.main.async { [weak self] in
                print(localValue)
                guard let strongSelf = self,
                    let docView = strongSelf.logview?.documentView else { return }
                docView.insertText(localValue)
            }
        }
    }
    
    fileprivate lazy var binaryURL: URL = {
        let mainBundle = Bundle.main.bundleURL
            .appendingPathComponent("Contents/Resources", isDirectory: true)
            .appendingPathComponent("demogod")
        log = "Running process \(mainBundle.absoluteString)"
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
    fileprivate func processRun() {
        self.processQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            if strongSelf.process != nil { return }

            let proc = Process()
            let binUrl = strongSelf.binaryURL
            proc.executableURL = binUrl
            strongSelf.process = proc
            
            strongSelf.attachToPipes(forProcess: proc)
            try? proc.run()

            proc.waitUntilExit()
            strongSelf.process = nil
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
                log = "No Stdin or stdout"
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
            log = "sendEOF but no standard in"
            return }
        stdIn.fileHandleForWriting.closeFile()
    }
    
    fileprivate func sendString(toProcess proc: Process,_ value: String) {
        guard let stdIn = proc.standardInput as? Pipe,
            let data = value.data(using: .utf8) else {
                log = "sendEOF but no standard in or data is not in utf8 formate"
                return }
        stdIn.fileHandleForWriting.write(data)
    }
    
    
}


//
//  MainWindowController.swift
//  demogodApp
//
//  Created by PersonA on 9/2/19.
//

import Foundation
import AppKit

class MainWindowController: NSWindowController {
    
    
    //MARK:- private properties
    //MARK:
    fileprivate lazy var theViewController: ViewController = {
        let vc = self.contentViewController as! ViewController
        return vc
    }()
    
    var serverConfig = RequestServerContext()
    
    @IBOutlet weak var portNumber: NSTextField?
    @IBOutlet weak var toolbarCommand: NSTextField?
    
    @IBAction func requestToStart(_ sender: NSButton) {
        if sender.state == .off {
            startSequence()
        } else {
            theViewController.requestToStop()
        }
        sender.title = (sender.state == .on ?"" :"")
    }
    
    @IBAction func requestToSendCmd(_ sender: NSButton) {
        guard let valueToSend = toolbarCommand?.stringValue else {
            return
        }
        theViewController.requestToSend(Value: "\(valueToSend)\n")
    }
    
    
    //MARK:- Private functions
    //MARK:
    fileprivate func requestWorkingFolder(withResult result: @escaping (URL?)->()) {
        let chooseFile = NSOpenPanel()
        chooseFile.showsResizeIndicator = true
        chooseFile.showsHiddenFiles = true
        chooseFile.canChooseDirectories = true
        chooseFile.canChooseFiles = false
        chooseFile.canCreateDirectories = true
        chooseFile.allowsMultipleSelection = false

        chooseFile.runModal()
        let url = chooseFile.url
        result(url)
    }
    
    fileprivate func startSequence() {
        requestWorkingFolder { [weak self] (url) in
            guard let strongSelf = self, let url = url else { return }
            var startCmd = CliCmd.server(.run(nil))
            if let port = strongSelf.portNumber?.integerValue, port > 1024 {
                startCmd = CliCmd.server(.run(CLIRequestServerContext(port: port)))
            }
            var cfg = strongSelf.serverConfig
            cfg.storeUrl = url
            let serveCmd = CliCmd.server(.update(cfg))
            strongSelf.theViewController.requestToStart(withCommands: [startCmd.cmd,
                                                                       serveCmd.cmd])
        }
    }
    
    
}

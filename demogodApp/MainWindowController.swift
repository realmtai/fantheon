//
//  MainWindowController.swift
//  demogodApp
//
//  Created by PersonA on 9/2/19.
//

import Foundation
import AppKit

class MainWindowController: NSWindowController {
    
    
    //MARK:- Life Cycle
    //MARK:
    

    //MARK:- private properties
    //MARK:
    fileprivate lazy var theViewController: ViewController = {
        let vc = self.contentViewController as! ViewController
        return vc
    }()
    
    @IBOutlet weak var portNumber: NSTextField?
    @IBOutlet weak var toolbarCommand: NSTextField?
    
    @IBAction func requestToStart(_ sender: NSButton) {
        startSequence()
    }
    
    @IBAction func requestToSendCmd(_ sender: NSButton) {
        guard let valueToSend = toolbarCommand?.stringValue else {
            return
        }
        theViewController.requestToSend(Value: "\(valueToSend)\n")
    }
    
    fileprivate func requestWorkingFolder(withResult result: @escaping (URL?)->()) {
        guard let window = self.window else {
            result(nil)
            return
        }
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
    
    func startSequence() {
        requestWorkingFolder { [weak self] (url) in
            guard let strongSelf = self, let url = url else { return }
            
            var cmd = CliCmd.server(.run(nil))
            if let port = strongSelf.portNumber?.integerValue, port > 1024 {
                cmd = CliCmd.server(.run(CLIRequestServerContext(port: port)))
            }
            strongSelf.theViewController.requestToStart(withCommands: [cmd.cmd])
        }
    }
    
    
}

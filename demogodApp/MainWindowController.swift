//
//  MainWindowController.swift
//  demogodApp
//
//  Created by PersonA on 9/2/19.
//

import Foundation
import AppKit

class MainWindowController: NSWindowController {
    
    lazy var theViewController: ViewController = {
        let vc = self.contentViewController as! ViewController
        return vc
    }()
    
    @IBOutlet weak var portNumber: NSTextField?
    @IBOutlet weak var toolbarCommand: NSTextField?
    
    @IBAction func requestToStart(_ sender: NSButton) {
        var cmd = CliCmd.server(.run(nil))
        if let port = portNumber?.integerValue, port > 1024 {
            cmd = CliCmd.server(.run(CLIRequestServerContext(port: port)))
        }
        theViewController.requestToStart(withCommands: [cmd.cmd])
    }
    
    @IBAction func requestToSendCmd(_ sender: NSButton) {
        guard let valueToSend = toolbarCommand?.stringValue else {
            return
        }
        theViewController.requestToSend(Value: "\(valueToSend)\n")
    }
    
    
}

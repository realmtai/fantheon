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
    
    @IBOutlet weak var toolbarCommand: NSTextField?
    
    @IBAction func requestToStart(_ sender: NSButton) {
        theViewController.requestToStart()
    }
    
    @IBAction func requestToSendCmd(_ sender: NSButton) {
        guard let valueToSend = toolbarCommand?.stringValue else {
            return
        }
        theViewController.requestToSend(Value: "\(valueToSend)\n")
    }
    
    
}

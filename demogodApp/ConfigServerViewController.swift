//
//  ConfigServerViewController.swift
//
//

import Foundation
import AppKit

class ConfigServerViewController: NSViewController {
    
    //MARK:- Public API
    //MARK:
    var config = RequestServerContext()
    var updateConfigAction: ((RequestServerContext)->())? = nil
    
    //MARK:- User Actions
    //MARK:
    @IBAction func requestUpdateConfig(_ sender: NSButton) {
        defer { dismiss(self) }
        
        guard let action = updateConfigAction else { return }
        action(config)
    }
    
}

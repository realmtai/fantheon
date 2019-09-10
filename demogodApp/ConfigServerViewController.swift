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
    
    //MARK:- UI
    //MARK:

    @IBOutlet weak var locationLabel: NSTextField!
    @IBAction func requestToChangeStoreURL(_ sender: NSButton) {
        requestWorkingFolder {[weak self] (url) in
            guard let strongSelf = self else { return }
            strongSelf.config.storeUrl = (url ?? strongSelf.config.storeUrl)
            strongSelf.locationLabel.stringValue = strongSelf.config.storeUrl.absoluteString
        }
    }
    
    @IBOutlet weak var profileTextField: NSTextField!
    @IBAction func requestToUpdateProfile(_ sender: NSTextField) {
        config.profile = sender.stringValue
    }
    
    @IBAction func requestUpdateConfig(_ sender: NSButton) {
        defer { dismiss(self) }
        guard let action = updateConfigAction else { return }
        
        // need to un-focus when user is editing and click on update
        profileTextField.window?.makeFirstResponder(nil)
        
        action(config)
    }
    
    func updateUI(fromConfig cfg: RequestServerContext) {
        locationLabel.stringValue = cfg.storeUrl.absoluteString
        profileTextField.stringValue = cfg.profile
    }
    
    //MARK:- Life Cycle
    //MARK:

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI(fromConfig: config)
    }
    
    
}

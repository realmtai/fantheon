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
    
    static let previewDefaultString =  "<~~~~ No Preview Available, edit to override ~~~~>"

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
    
    @IBOutlet var defaultRespTextView: NSTextView!
    @IBOutlet weak var selectedFileLabel: NSTextField!
    @IBAction func requestToSelectDefaultFile(_ sender: NSButton) {
        requestFile { [weak self] (url) in
            guard let strongSelf = self, let url = url else { return }
            strongSelf.selectedFileLabel.stringValue = url.absoluteString
            
            guard let fData = (try? Data(contentsOf: url)) else { return }
            strongSelf.config.defaultJSONData = fData
            
            let preview = String(data: fData, encoding: .utf8)
                ?? ConfigServerViewController.previewDefaultString
            
            strongSelf.defaultRespTextView.string = preview
        }
    }
    
    @IBAction func requestUpdateConfig(_ sender: NSButton) {
        defer { dismiss(self) }
        guard let action = updateConfigAction else { return }
        view.window?.makeFirstResponder(nil)
        action(config)
    }
    
    func updateUI(fromConfig cfg: RequestServerContext) {
        locationLabel.stringValue = cfg.storeUrl.absoluteString
        profileTextField.stringValue = cfg.profile
        defaultRespTextView.string = (String(data: cfg.defaultJSONData, encoding: .utf8)
            ?? ConfigServerViewController.previewDefaultString)
    }
    
    //MARK:- Life Cycle
    //MARK:

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI(fromConfig: config)
    }

}

extension ConfigServerViewController: NSTextViewDelegate {
    
    func textDidEndEditing(_ notification: Notification) {
        guard let textObject = notification.object as? NSText,
            textObject.string.count > 1
            else { return
        }
        config.defaultJSONData = (textObject.string.data(using: .utf8) ?? config.defaultJSONData)
    }

}

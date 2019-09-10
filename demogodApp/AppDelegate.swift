//
//  AppDelegate.swift
//
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}



extension NSResponder {
    
    func requestWorkingFolder(withResult result: @escaping (URL?)->()) {
        DispatchQueue.main.async {
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
    }
    
}

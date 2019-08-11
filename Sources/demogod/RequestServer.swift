//
//  RequestServer.swift
//  CHTTPParser
//
//

import Kitura
import Foundation
import HeliumLogger
import LoggerAPI


struct RequestServerConfig {
    var debugLevel: LoggerMessageType = .debug
    var usingStoreUrl: URL = URL(fileURLWithPath: "/Users/Yong/testGround/henny", isDirectory: true)
    var defaultJSONData: Data = (try! JSONSerialization.data(withJSONObject: [:],
                                                             options: .prettyPrinted))
}


class RequestServer {
    
    fileprivate let router = Router()
    fileprivate let config: RequestServerConfig
    
    fileprivate var profile: String = "default"
    
    fileprivate let workQueue = DispatchQueue(label: "com.downloadthebear.requestServer.workq")
    
    fileprivate func setupRoutes() {
        Log.info("Setup Routes")
        
        router.all { [weak self] (request, resp, next) in
            guard let strongSelf = self else { return }
            let storePath = strongSelf.config.usingStoreUrl
            let fileName = String.fileName(fromRequest: request)
            let profileName = strongSelf.profile
            let containedFolder = storePath
                .appendingPathComponent(profileName, isDirectory: true)
            let fileUrl = containedFolder
                .appendingPathComponent(fileName, isDirectory: false)
            
            let data = strongSelf.config.defaultJSONData
            
            resp.headers.setType("json")
            if FileManager.default.isReadableFile(atPath: fileUrl.path) {
                guard let file = try? Data(contentsOf: fileUrl) else {
                    try resp
                        .send(data: data)
                        .status(.accepted)
                        .end()
                    return
                }
                try resp
                    .send(data: file)
                    .status(.accepted)
                    .end()
                
            } else {
                if !FileManager.default.isReadableFile(atPath: containedFolder.path) {
                    try? FileManager.default.createDirectory(atPath: containedFolder.path, withIntermediateDirectories: true, attributes: nil)
                }
                try? data.write(to: fileUrl, options: .atomicWrite)
                
                try resp
                    .send(data: data)
                    .status(.created)
                    .end()
            }
        }
    }
    
    //MARK:- Public API
    //MARK:
    
    init(config: RequestServerConfig = RequestServerConfig()) {
        self.config = config
    } 

    func run(onPort port: Int = 8090) {
        self.workQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            Log.info("starting the server")
            HeliumLogger.use(.debug)
            
            strongSelf.setupRoutes()
            
            Kitura.addHTTPServer(onPort: port, with: strongSelf.router)
            Kitura.run()
        }
    }
    
    func stop() {
        self.workQueue.async { [weak self] in
            guard let _ = self else { return }
            Log.info("stopping the server")
            Kitura.stop()
        }
    }
}

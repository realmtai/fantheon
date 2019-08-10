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
    let router = Router()
    let config: RequestServerConfig
    
    var profile: String = "default"
    
    let workQueue = DispatchQueue(label: "com.downloadthebear.requestServer.workq")
    
    init(config: RequestServerConfig = RequestServerConfig()) {
        self.config = config
    }
    
    func setupRoutes() {
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
    
    func run() {
        Log.info("starting the server")
        self.workQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            HeliumLogger.use(.debug)
            
            strongSelf.setupRoutes()
            
            Kitura.addHTTPServer(onPort: 8090, with: strongSelf.router)
            Kitura.run()
        }
    }
    
    func stop() {
        Log.info("stopping the server")
        self.workQueue.async { [weak self] in
            guard let _ = self else { return }
            Kitura.stop()
        }
    }
}

//
//  RequestServer.swift
//  CHTTPParser
//
//

import Kitura
import Foundation
import HeliumLogger
import LoggerAPI

struct RequestServerDevConfig {
    var debugLevel: LoggerMessageType = .debug
}

class RequestServer {
    
    fileprivate let router = Router()

    fileprivate let workQueue = DispatchQueue(label: "com.downloadthebear.requestServer.workq")
    fileprivate var config: RequestServerContext
    
    fileprivate var devConfig = RequestServerDevConfig()
    
    fileprivate func setupRoutes() {
        Log.info("Setup Routes")
        
        router.all { [weak self] (request, resp, next) in
            guard let strongSelf = self else { return }
            let config = strongSelf.config
            
            let storePath = config.storeUrl
            let fileName = String.fileName(fromRequest: request)
            let profileName = config.profile
            let containedFolder = storePath
                .appendingPathComponent(profileName, isDirectory: true)
            let fileUrl = containedFolder
                .appendingPathComponent(fileName, isDirectory: false)
            
            let data = config.defaultJSONData
            
            resp.headers.setType(request.urlURL.pathExtension)
            
            if FileManager.default.isReadableFile(atPath: fileUrl.path) {
                guard let file = try? Data(contentsOf: fileUrl) else {
                    try resp.send(data: data).status(.accepted).end()
                    return
                }
                try resp.send(data: file).status(.accepted).end()
                
            } else {
                if !FileManager.default.isReadableFile(atPath: containedFolder.path) {
                    try? FileManager.default.createDirectory(atPath: containedFolder.path,
                                                             withIntermediateDirectories: true,
                                                             attributes: nil)
                }
                try? data.write(to: fileUrl, options: .atomicWrite)
                try resp.send(data: data).status(.created).end()
                
            }
            
            let metaFile = containedFolder
                .appendingPathComponent(String.metaFileName(fromRequest: request),
                                        isDirectory: false)
            if let metaData = RequestServer.processAndCreate(metafileFrom: request).data(using: .utf8) {
                try? metaData.append(fileURL: metaFile)
            }
        }
    }
    
    static fileprivate func processAndCreate(metafileFrom req: RouterRequest) -> String {
        let result =
"""
### Sample URL
`\(req.urlURL.absoluteString)`
### Sample Query
\(req.queryParameters.description)


"""
        return result
    }
    
    fileprivate func processAndApply(config cfg: RequestServerContext) {
        HeliumLogger.use(devConfig.debugLevel)
    }
    
    //MARK:- Public API
    //MARK:
    
    init(config: RequestServerContext = RequestServerContext()) {
        self.config = config
    }
    
    func update(config cfg: RequestServerContext) {
        self.workQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.config = cfg
            strongSelf.processAndApply(config: cfg)
        }
    }
    
    func requestServer(config cfgReq: @escaping ((RequestServerContext)->())) {
        self.workQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            cfgReq(strongSelf.config)
        }
    }

    func run(onPort port: Int) {
        self.workQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            HeliumLogger.use(strongSelf.devConfig.debugLevel)
            
            Log.info("starting the server on port \(port)")
            strongSelf.setupRoutes()
            Kitura.addHTTPServer(onPort: port, with: strongSelf.router)
            Kitura.start()
        }
    }
    
    func stop() {
        self.workQueue.async {
            Kitura.stop()
            Log.info("stopped the server")
        }
    }
    
}

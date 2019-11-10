//
//  SystemFrameworkExtenstion.swift
//  CHTTPParser
//
//

import Kitura
import Foundation


extension String {
    
    static func fileName(fromRequest req: RouterRequest) -> String {
        let method = req.method.rawValue.filteredForFileSystem()
        let path = (req.parsedURL.path ?? "/").split(separator: "/").joined(separator: ":").filteredForFileSystem()
        
        return [method, path].joined(separator: ":")
    }
    
    static func metaFileName(fromRequest req: RouterRequest) -> String {
        let meta = "_"
        let path = fileName(fromRequest: req)
        return [meta, path].joined(separator: "")
    }
    
    fileprivate static let okayChars = Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890-_.:")
    func filteredForFileSystem() -> String {
        return self.filter { String.okayChars.contains($0) }
    }
    
    var statusCode: HTTPStatusCode {
        guard let intValue = Int(self),
            let code = HTTPStatusCode(rawValue: intValue) else {
            return .accepted
        }
        return (code == .unknown) ?.accepted :code
    }
    
}


extension NSError {
    
    static var CLICmdNotFound: Error {
        return NSError(domain: "com.downloadthebear.cliCommand.notFound.error",
                       code: 000,
                       userInfo: [NSLocalizedDescriptionKey: "Unable to find the command"])
    }
    
    static var CLICmdParsing: Error {
        return NSError(domain: "com.downloadthebear.cliCommand.parse.error",
                       code: 000,
                       userInfo: [NSLocalizedDescriptionKey: "Unable parse command"])
    }
    
    static var MAINRequestServerMissing: Error {
        return NSError(domain: "com.downloadthebear.main.runtime.error",
                       code: 000,
                       userInfo: [NSLocalizedDescriptionKey: "Unable to locate request server"])
    } 
    
}


extension Data {
    
    func append(fileURL: URL) throws {
        if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        }
        else {
            try write(to: fileURL, options: .atomic)
        }
    }
    
}


extension FileManager {
    
    func fileNames(at directory: URL, skipsHiddenFiles: Bool = true) -> [String] {
        let fileURLs = try? contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: skipsHiddenFiles ? .skipsHiddenFiles : [] )
        let fileNames = (fileURLs ?? []).map({ $0.lastPathComponent })
        return fileNames
    }
    
    static func tags(forURL url:URL) -> [String] {
        guard let res = (try? url.resourceValues(forKeys: [.tagNamesKey])),
            let tags = res.tagNames else {
            return []
        }
        return tags
    }
    
}

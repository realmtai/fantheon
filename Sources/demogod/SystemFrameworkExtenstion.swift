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
        let path = (req.parsedURL.path ?? "/").filteredForFileSystem()
        return [method, path].joined(separator: ".")
    }
    
    static func metaFileName(fromRequest req: RouterRequest) -> String {
        let meta = "_"
        let path = fileName(fromRequest: req)
        return [meta, path].joined(separator: "")
    }
    
    fileprivate static let okayChars = Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890-_.")
    func filteredForFileSystem() -> String {
        return self.filter { String.okayChars.contains($0) }
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

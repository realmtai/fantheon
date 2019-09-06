//
//  CLIContext.swift
//  demogod
//
import Foundation

enum CliCmd {
    enum ServerVerb {
        case run(CLIRequestServerContext?)
        case stop
    }
    case server(ServerVerb)
}

extension CliCmd {
    var noun: String {
        switch self {
        case .server(_): return "server"
        }
    }
    
    var verb: String {
        switch self {
        case .server(let verb):
            switch verb {
            case .run(_): return "run"
            case .stop: return "stop"
            }
        }
    }
    
    var cmd: String {
        switch self {
        case .server(let vb):
            switch vb {
            case .run(let ctx): return CliCmd.buildCmd(noun, verb, ctx?.JSONString)
            case .stop: return CliCmd.buildCmd(noun, verb, nil)
            }
        }
    }
    
    static func buildCmd(_ noun: String,_ verb: String,_ ctx: String?) -> String {
        return [noun, verb, ctx, "\n"].compactMap({$0}).joined(separator: " ")
    }
}



struct CLIRequestServerContext: Codable {
    var port: Int = 8090
}



extension Encodable {
    var JSONString: String {
        guard let jData = try? JSONSerialization.data(withJSONObject: self),
            let result = String(data: jData, encoding: .utf8) else {
                return ""
        }
        return result
    }
}



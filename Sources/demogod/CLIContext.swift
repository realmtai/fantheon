//
//  CLIContext.swift
//  demogod
//
import Foundation

//MARK:- CLI Commands
//MARK:
/////////////////////////////

enum CliCmd {
    enum ServerVerb {
        // CTL-D
        // case stop
        case run(CLIRequestServerContext?)
        case update(RequestServerContext?)
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
            case .update: return "update"
            }
        }
    }
    
    var cmd: String {
        switch self {
        case .server(let vb):
            switch vb {
            case .run(let ctx): return CliCmd.buildCmd(noun, verb, ctx?.JSONString)
            case .update(let ctx): return CliCmd.buildCmd(noun, verb, ctx?.JSONString)
            }
        }
    }
    
    static func buildCmd(_ noun: String,_ verb: String,_ ctx: String?) -> String {
        return [noun, verb, ctx, "\n"].compactMap({$0}).joined(separator: " ")
    }
}


//MARK:- CLI Commands Context
//MARK:
/////////////////////////////

struct CLIRequestServerContext: Codable {
    var port: Int = 8090
}



struct RequestServerContext: Codable {
    var storeUrl: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    var profile: String = "default"
    var defaultJSONData: Data = (try! JSONSerialization.data(withJSONObject: [:], options: .prettyPrinted))
}

//MARK:- CLI Commands Context Encoding
//MARK:
//////////////////////////////////////

extension Encodable {
    var JSONString: String? {
        guard let jData = try? JSONEncoder().encode(self),
            let result = String(data: jData, encoding: .utf8) else {
                return nil
        }
        return result
    }
}



import Kitura
import Foundation
import HeliumLogger
import LoggerAPI



let server = RequestServer()
let cli = CLIServer()



cli.register { (output) in
    Log.debug(output)
}

cli.register(command: CLICommand(noun: CLINounTypes.server.rawValue,
                                 verb: "run",
                                 action: { [weak server] (context) -> (Error?) in
                                    guard let server = server,
                                        let jData = context.data(using: .utf8) else {
                                            return NSError.MAINRequestServerMissing
                                    }
                                    let context = (try? JSONDecoder().decode(CLIRequestServerContext.self, from: jData))
                                        ?? CLIRequestServerContext()
                                    server.run(onPort: context.port)
                                    return nil
    }, help: { () -> (String) in
        return ""
}))

cli.register(command: CLICommand(noun: CLINounTypes.server.rawValue,
                                 verb: "stop",
                                 action: { [weak server] (context) -> (Error?) in
                                    guard let server = server else {
                                        return NSError.MAINRequestServerMissing
                                    }
                                    server.stop()
                                    return nil
    }, help: { () -> (String) in
        return ""
}))




func main() {
    while let line = readLine() {
        cli.enqueue(stringCommand: line)
    }
    server.stop()
}

main()

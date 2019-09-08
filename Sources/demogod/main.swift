import Kitura
import Foundation
import HeliumLogger
import LoggerAPI



let server = RequestServer()
let cli = CLIServer()



cli.register { (output) in
    Log.info(output)
}

let _ = {
    let cmd = CliCmd.server(.run(nil))
    cli.register(command: CLICommand(noun: cmd.noun,
                                     verb: cmd.verb,
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
}()


let _ = {
    let cmd = CliCmd.server(.update(nil))
    cli.register(command: CLICommand(noun: cmd.noun,
                                     verb: cmd.verb,
                                     action: { [weak server] (context) -> (Error?) in
                                        guard let server = server,
                                            let jData = context.data(using: .utf8) else {
                                                return NSError.MAINRequestServerMissing
                                        }
                                        let context = (try? JSONDecoder().decode(RequestServerContext.self, from: jData))
                                            ?? RequestServerContext()
                                        server.update(config: context)
                                        return nil
        }, help: { () -> (String) in
            return ""
    }))
}()








func main() {
    while let line = readLine() {
        cli.enqueue(stringCommand: line)
    }
    server.stop()
}

main()

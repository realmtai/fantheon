import Kitura
import Foundation
import HeliumLogger
import LoggerAPI



let server = RequestServer()

while let line = readLine() {
    if line.caseInsensitiveCompare("start") == .orderedSame {
        server.run()
    }
}

server.stop()

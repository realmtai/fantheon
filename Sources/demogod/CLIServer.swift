//
//  CLIServer.swift
//  demogod
//
//

import Foundation


struct CLICommand {
    let noun: String
    let verb: String

    let action: ((String)->(Error?))
    let help: (()->(String))
}


class CLIServer {
    
    fileprivate let outputWorkQueue = DispatchQueue(label: "com.downloadthebear.CLIServer.output.workq")
    fileprivate var outputClient: ((String)->())? = nil
    
    fileprivate let workQueue = DispatchQueue(label: "com.downloadthebear.CLIServer.workq")
    
    fileprivate var cliCmdDataStore: [String: [String: CLICommand]] = [:]
    
    fileprivate var commandQueue: [String] = [] {
        didSet {
            self.workQueue.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.drainCommands()
            }
        }
    }
    
    fileprivate var output: String? {
        didSet {
            guard let localValue = output else { return }
            self.outputWorkQueue.async { [weak self] in
                guard let strongSelf = self,
                    let client = strongSelf.outputClient else { return }
                client(localValue)
            }
        }
    }
    
    fileprivate func drainCommands() {
        while !commandQueue.isEmpty {
            let command = commandQueue.removeFirst()
            guard let err = processCommand(fromString: command) else {
                continue
            }
            output = "Input cmd ~> \(command)\nError <~ \(err.localizedDescription)"
        }
    }
    
    fileprivate func processCommand(fromString cmdStr: String) -> Error? {
        var tokens = cmdStr.split(separator: " ", maxSplits: 2)
        if tokens.count < 2 { return NSError.CLICmdParsing }
        
        let noun = String(tokens.removeFirst())
        let verb = String(tokens.removeFirst())
        let jsonContext = String(tokens.popLast() ?? "")
        
        guard let command = cliCmdDataStore[noun]?[verb] else {
            return NSError.CLICmdNotFound
        }
        
        return command.action(jsonContext)
    }
    
    //MARK:- Public API
    //MARK:
    
    func enqueue(stringCommand cmdStr: String) {
        self.workQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.commandQueue.append(cmdStr)
        }
    }
    
    func register(command cmd: CLICommand) {
        self.workQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            var verbDict: [String: CLICommand] = strongSelf.cliCmdDataStore[cmd.noun] ?? [:]
            verbDict[cmd.verb] = cmd
            strongSelf.cliCmdDataStore[cmd.noun] = verbDict
        }
    }
    
    func register(outputClient client: @escaping ((String)->())) {
        self.workQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.outputClient = client
        }
    }
    
}





import XCTest
extension demogodTests {

    func testCLIParsing() {
        
        let _ = {
            let cli = CLIServer()
            let err = cli.processCommand(fromString: "hello")
            XCTAssertEqual((err! as NSError), (NSError.CLICmdParsing as NSError))
        }()
        
        let _ = {
            let cli = CLIServer()
            let err = cli.processCommand(fromString: "hello world")
            XCTAssertEqual((err! as NSError), (NSError.CLICmdNotFound as NSError))
        }()
        
    }
    
    func testDequeueEnqueu()  {
        let _ = {
            let cli = CLIServer()
            let exp = expectation(description: "exit and completed")
            
            cli.register(command: CLICommand(noun: "hello", verb: "world", action: { (input) -> (Error?) in
                XCTAssertEqual(input, "input 1")
                return nil
            }, help: { () -> (String) in
                return ""
            }))
            
            cli.register(command: CLICommand(noun: "hello", verb: "world2", action: { (input) -> (Error?) in
                XCTAssertEqual(input, "input 2")
                return nil
            }, help: { () -> (String) in
                return ""
            }))
            
            cli.register(outputClient: { (input) in
                XCTAssertTrue(false)
            })
            
            cli.enqueue(stringCommand: "hello world input 1")
            cli.enqueue(stringCommand: "hello world input 1")
            cli.enqueue(stringCommand: "hello world2 input 2")
            
            cli.workQueue.async {
                exp.fulfill()
            }
            waitForExpectations(timeout: 0.5, handler: nil)
        }()
        
        let _ = {
            let cli = CLIServer()
            let exp = expectation(description: "exit and completed")
            
            cli.register(command: CLICommand(noun: "hello", verb: "world", action: { (input) -> (Error?) in
                if input == "input 1" {
                    return nil
                }
                return NSError.CLICmdParsing
            }, help: { () -> (String) in
                return ""
            }))
            
            cli.register(command: CLICommand(noun: "hello", verb: "world2", action: { (input) -> (Error?) in
                XCTAssertEqual(input, "input 2")
                return nil
            }, help: { () -> (String) in
                return ""
            }))
            
            cli.register(outputClient: { (input) in
                // Should print at least the error
                XCTAssertNotEqual(input, "")
                exp.fulfill()
            })
            
            cli.enqueue(stringCommand: "hello world input 1")
            cli.enqueue(stringCommand: "hello world2 input 2")
            cli.enqueue(stringCommand: "hello world input 1")
            cli.enqueue(stringCommand: "hello world2 input 2")
            // error command
            cli.enqueue(stringCommand: "hello world input 2")

            waitForExpectations(timeout: 0.5, handler: nil)
        }()
    }
    
}

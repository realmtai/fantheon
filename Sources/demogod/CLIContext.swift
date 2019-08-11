//
//  CLIContext.swift
//  demogod
//
//

import Foundation

//struct HW: Codable {
//    var hello: String = "world"
//    var foo: String?
//}
//
//let jData = try! JSONSerialization.data(withJSONObject: ["hello": "worrrrld"], options: .prettyPrinted)
//
////let jData = try! JSONSerialization.data(withJSONObject: [:], options: .prettyPrinted)
//
//print((try? JSONDecoder().decode(HW.self, from: jData)) ?? HW())

struct CLIRequestServerContext: Codable {
    var port: Int = 8090
}

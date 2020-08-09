//
//  main.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/4/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation


let file = #file
let dataDlib = file.replacingOccurrences(of: "", with: "")
let swiftSyntaxParserDylib = Resource(
    encodedData: try Data(contentsOf: URL(fileURLWithPath: dataDlib)).base64EncodedString(),
    fileName: "lib_InternalSwiftSyntaxParser.dylib"
)
loadDylibs([swiftSyntaxParserDylib]) {
    exit(main(arguments: ProcessInfo.processInfo.arguments))
}

func main(arguments: [String]) -> Int32 {
  let program = Program(usage: "<method>",
                        overview: "Mockingbird mock generator",
                        commands: [GenerateCommand.self,
                                   ConfigureCommand.self,
                                   InstallCommand.self,
                                   UninstallCommand.self,
                                   DownloadCommand.self,
                                   TestbedCommand.self,
                                   VersionCommand.self])
  return program.run(with: arguments)
}


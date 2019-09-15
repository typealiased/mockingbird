//
//  main.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/4/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation

func main(arguments: [String]) {
  let program = Program(usage: "<method>",
                        overview: "Mockingbird mock generator",
                        commands: [GenerateCommand.self,
                                   InstallCommand.self,
                                   UninstallCommand.self,
                                   TestbedCommand.self,
                                   VersionCommand.self])
  program.run(with: arguments)
}

main(arguments: ProcessInfo.processInfo.arguments)

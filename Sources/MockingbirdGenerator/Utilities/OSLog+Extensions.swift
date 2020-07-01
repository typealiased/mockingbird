//
//  OSLog+Extensions.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 9/12/19.
//

import Foundation
import os.signpost

private enum Constants {
  static let subsystem = "co.bird.mockingbird"
}

public enum SignpostType {
  case createDylibs
  case runProgram
  case parseArguments
  case parseXcodeProject
  case extractSources
  case checkCache
  case parseTests
  case parseFiles
  case processTypes
  case renderMocks
  case writeFiles
  case cacheMocks
  
  public var name: StaticString {
    switch self {
    case .createDylibs: return "Create Dylibs"
    case .runProgram: return "Run Program"
    case .parseArguments: return "Parse Arguments"
    case .parseXcodeProject: return "Parse Xcode Project"
    case .extractSources: return "Extract Sources"
    case .checkCache: return "Check Cache"
    case .parseTests: return "Parse Tests"
    case .parseFiles: return "Parse Files"
    case .processTypes: return "Process Types"
    case .renderMocks: return "Render Mocks"
    case .writeFiles: return "Write Files"
    case .cacheMocks: return "Cache Mocks"
    }
  }
}

@available(OSX 10.14, *)
public struct Signpost {
  let id: OSSignpostID
  let type: SignpostType
  
  fileprivate init(_ type: SignpostType) {
    self.id = OSSignpostID(log: .pointsOfInterest)
    self.type = type
  }
}

@available(OSX 10.14, *)
public extension OSLog {
  static var pointsOfInterest: OSLog {
    return OSLog(
      subsystem: Constants.subsystem,
      category: .pointsOfInterest
    )
  }
  
  static func beginSignpost(_ type: SignpostType) -> Signpost {
    let signpost = Signpost(type)
    os_signpost(.begin,
                log: .pointsOfInterest,
                name: signpost.type.name,
                signpostID: signpost.id)
    return signpost
  }
  
  static func endSignpost(_ signpost: Signpost) {
    os_signpost(.end,
                log: .pointsOfInterest,
                name: signpost.type.name,
                signpostID: signpost.id)
  }
}

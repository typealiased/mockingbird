//
//  TestTarget.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 6/10/20.
//

import Foundation
import PathKit

public class TestTarget: CodableTarget {
  public let mockedTypeNames: [Path: Set<String>]
  public let projectHash: String
  public let cliVersion: String
  public let configHash: String
  
  enum CodingKeys: String, CodingKey {
    case mockedTypeNames
    case projectHash
    case cliVersion
    case configHash
  }
  
  public init<T: Target>(from target: T,
                         sourceRoot: Path,
                         mockedTypeNames: [Path: Set<String>],
                         projectHash: String,
                         cliVersion: String,
                         configHash: String,
                         environment: () -> [String: Any]) throws {
    self.mockedTypeNames = mockedTypeNames
    self.projectHash = projectHash
    self.cliVersion = cliVersion
    self.configHash = configHash
    
    var ignoredDependencies = Set<String>()
    try super.init(from: target,
                   sourceRoot: sourceRoot,
                   dependencies: [],
                   ignoredDependencies: &ignoredDependencies,
                   environment: environment)
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    self.mockedTypeNames = try container.decode([Path: Set<String>].self, forKey: .mockedTypeNames)
    self.projectHash = try container.decode(String.self, forKey: .projectHash)
    self.cliVersion = try container.decode(String.self, forKey: .cliVersion)
    self.configHash = try container.decode(String.self, forKey: .configHash)
    
    try super.init(from: decoder)
  }
  
  public override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    try container.encode(mockedTypeNames, forKey: .mockedTypeNames)
    try container.encode(projectHash, forKey: .projectHash)
    try container.encode(cliVersion, forKey: .cliVersion)
    try container.encode(configHash, forKey: .configHash)
    
    try super.encode(to: encoder)
  }
}

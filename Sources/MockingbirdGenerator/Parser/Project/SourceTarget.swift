//
//  SourceTarget.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 6/9/20.
//

import Foundation
import PathKit
import XcodeProj

public class SourceTarget: CodableTarget {
  public let supportingFilePaths: [SourceFile]
  public let projectHash: String
  public let outputHash: String
  public let mockedTypesHash: String?
  public let targetPathsHash: String
  public let dependencyPathsHash: String
  public let cliVersion: String
  public let configHash: String
  
  enum CodingKeys: String, CodingKey {
    case supportingFilePaths
    case projectHash
    case outputHash
    case mockedTypesHash
    case targetPathsHash
    case dependencyPathsHash
    case cliVersion
    case configHash
  }
  
  public init<T: Target>(from target: T,
                         sourceRoot: Path,
                         supportPaths: [Path],
                         projectHash: String,
                         outputHash: String,
                         mockedTypesHash: String?,
                         targetPathsHash: String,
                         dependencyPathsHash: String,
                         cliVersion: String,
                         configHash: String,
                         ignoredDependencies: inout Set<String>,
                         environment: () -> [String: Any]) throws {
    self.supportingFilePaths = try supportPaths
      .map({ $0.absolute() })
      .sorted()
      .map({
        let data = (try? $0.read()) ?? Data()
        return try SourceFile(path: $0, hash: data.generateSha1Hash())
      })
    self.targetPathsHash = targetPathsHash
    self.dependencyPathsHash = dependencyPathsHash
    self.projectHash = projectHash
    self.outputHash = outputHash
    self.mockedTypesHash = mockedTypesHash
    self.cliVersion = cliVersion
    self.configHash = configHash
    
    try super.init(from: target,
                   sourceRoot: sourceRoot,
                   ignoredDependencies: &ignoredDependencies,
                   environment: environment)
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    self.supportingFilePaths =
      try container.decode([SourceFile].self, forKey: .supportingFilePaths)
    self.projectHash = try container.decode(String.self, forKey: .projectHash)
    self.outputHash = try container.decode(String.self, forKey: .outputHash)
    self.mockedTypesHash = try container.decode(String?.self, forKey: .mockedTypesHash)
    self.targetPathsHash = try container.decode(String.self, forKey: .targetPathsHash)
    self.dependencyPathsHash = try container.decode(String.self, forKey: .dependencyPathsHash)
    self.cliVersion = try container.decode(String.self, forKey: .cliVersion)
    self.configHash = try container.decode(String.self, forKey: .configHash)
    
    try super.init(from: decoder)
  }
  
  public override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    try container.encode(supportingFilePaths, forKey: .supportingFilePaths)
    try container.encode(projectHash, forKey: .projectHash)
    try container.encode(outputHash, forKey: .outputHash)
    try container.encode(mockedTypesHash, forKey: .mockedTypesHash)
    try container.encode(targetPathsHash, forKey: .targetPathsHash)
    try container.encode(dependencyPathsHash, forKey: .dependencyPathsHash)
    try container.encode(cliVersion, forKey: .cliVersion)
    try container.encode(configHash, forKey: .configHash)
    
    try super.encode(to: encoder)
  }
}

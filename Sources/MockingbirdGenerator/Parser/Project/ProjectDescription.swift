//
//  ProjectDescription.swift
//  MockingbirdGenerator
//
//  Created by typealias on 9/23/20.
//

import Foundation
import PathKit

public struct ProjectDescription: Codable, Hashable {
  public let targets: [TargetDescription]
}

public struct TargetDescription: Hashable {
  public let name: String
  public let c99name: String?
  public let type: String
  public let path: Path
  public let sources: [Path]
  public let dependencies: [String]
  
  public var productModuleName: String {
    return c99name ?? name.escapingForModuleName()
  }
}
/// Useful reference: https://github.com/apple/swift-package-manager/blob/main/Sources/PackageDescription/Target.swift
extension TargetDescription: Codable {
  public enum CodingKeys: String, CodingKey, CaseIterable {
    case name
    case c99name
    case type
    case path
    case sources
    case dependencies
  }
  
  /// Compatibility with Swift Package Manager JSON project descriptions.
  enum SwiftPackageManagerKeys: String, CodingKey, CaseIterable {
    case targetDependencies = "target_dependencies"
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.name = try container.decode(String.self, forKey: .name)
    self.c99name = try container.decodeIfPresent(String.self, forKey: .c99name)
    self.type = try container.decode(String.self, forKey: .type)
    self.sources = try container.decodeIfPresent([Path].self, forKey: .sources) ?? []
    
    if let path = try container.decodeIfPresent(Path.self, forKey: .path) {
      self.path = path
    } else {
      // if a custom path has not been set, swiftpm uses "Sources" and "Tests" relative to the package root.
      // https://github.com/apple/swift-package-manager/blob/main/Sources/PackageDescription/Target.swift
      let name = try container.decode(String.self, forKey: .name)
      let type = try container.decode(String.self, forKey: .type)
      if type == "regular" || type == "library" || type == "executable" {
        self.path = Path("Sources/\(name)")
      } else if type == "test" {
        self.path = Path("Tests/\(name)")
      } else {
        self.path = Path(name)
      }
    }
    
    let spmContainer = try decoder.container(keyedBy: SwiftPackageManagerKeys.self)
    let spmDependencies = try spmContainer.decodeIfPresent([String].self, forKey: .targetDependencies)
    
    if let dependencies = spmDependencies {
      self.dependencies = dependencies
    } else {
      struct PackageDumpDependenciesMissingError: Error { }
      do {
        if let packageDumpDependencies = try container.decodeIfPresent([[String: [String?]]].self, forKey: .dependencies) {
          self.dependencies = packageDumpDependencies.compactMap { element -> String? in
            let values = element["product"] ?? element["byName"] ?? element["target"]
            guard let first = values?.first else { return nil }
            return first
          }
        } else {
          throw PackageDumpDependenciesMissingError()
        }
      } catch DecodingError.typeMismatch, is PackageDumpDependenciesMissingError {
        if let names = try container.decodeIfPresent([String].self, forKey: .dependencies) {
          self.dependencies = names
        }
        else {
          self.dependencies = []
        }
      } catch {
        throw error
      }
    }
  }
}

public enum TargetDescriptionType: String {
  case library = "library"
  case test = "test"
  var isTestBundle: Bool { return self == .test }
}

public struct DescribedTargetDependency: TargetDependency {
  public let target: DescribedTarget?
}

public struct DescribedTarget: Target {
  public var name: String { return description.name }
  public let dependencies: [DescribedTargetDependency]
  public let description: TargetDescription
  public let productType: TargetDescriptionType?
  
  public init(from description: TargetDescription,
              descriptions: [TargetDescription],
              processedTargets: [String] = []) {
    self.description = description
    self.productType = TargetDescriptionType(rawValue: description.type)
    self.dependencies = description.dependencies.compactMap({ name in
      guard let dependency = descriptions.first(where: { $0.productModuleName == name })
      else { return nil }
      let attributedProcessedTargets = processedTargets + [dependency.productModuleName]
      guard !processedTargets.contains(dependency.productModuleName) else {
        logWarning("Breaking circular dependency \(attributedProcessedTargets.joined(separator: " -> "))")
        return nil
      }
      let target = DescribedTarget(from: dependency,
                                   descriptions: descriptions,
                                   processedTargets: attributedProcessedTargets)
      return DescribedTargetDependency(target: target)
    })
  }
  
  public func resolveProductModuleName(environment: () -> [String: Any]) -> String {
    return description.productModuleName
  }
  
  public func findSourceFilePaths(sourceRoot: Path) -> [Path] {
    return description.sources.map({ description.path + $0 })
  }
}

public class JSONProject {
  let path: Path
  let descriptions: [TargetDescription]
  
  required public init(path: Path) throws {
    self.path = path
    self.descriptions = try JSONDecoder().decode(ProjectDescription.self, from: path.read()).targets
  }
  
  public func targets(named name: String) -> [DescribedTarget] {
    return descriptions
      .filter({ $0.name == name })
      .map({ DescribedTarget(from: $0, descriptions: descriptions) })
  }
}

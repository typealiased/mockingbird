//
//  Path+ExpressibleByArgument.swift
//  MockingbirdCli
//
//  Created by typealias on 8/7/21.
//

import ArgumentParser
import Foundation
import PathKit
import MockingbirdGenerator

struct XcodeProjPath: ExpressibleByArgument {
  var path: Path
  
  init?(argument: String) {
    let path = Path(argument)
    if let containedXcodeProjects = try? path.findContainedXcodeProjects(),
       let firstXcodeProject = containedXcodeProjects.first {
      // The user provided the directory containing the Xcode project instead of the `.xcodeproj`.
      if containedXcodeProjects.count > 1 {
        logWarning("Found multiple Xcode projects in \(path.absolute())")
      }
      self.path = firstXcodeProject
    } else {
      self.path = path
    }
  }
  
  static var defaultCompletionKind: CompletionKind = .file(extensions: ["xcodeproj"])
}

extension XcodeProjPath: Encodable {
  func encode(to encoder: Encoder) throws {
    try OptionArgumentEncoding.encode(path, with: encoder)
  }
}

extension XcodeProjPath: InferableArgument {
  init?(context: ArgumentContext) throws {
    if let xcodebuildProjectPath = context.environment["PROJECT_FILE_PATH"] {
      path = Path(xcodebuildProjectPath)
      return
    }
    
    let containedXcodeProjects = try context.workingPath.findContainedXcodeProjects()
    if let firstXcodeProject = containedXcodeProjects.first {
      if containedXcodeProjects.count > 1 {
        logWarning("Found multiple Xcode projects in \(context.workingPath.absolute())")
      }
      log("Using inferred Xcode project at \(firstXcodeProject.absolute())")
      path = firstXcodeProject
    } else {
      return nil
    }
  }
}

extension XcodeProjPath: ValidatableArgument {
  func validate(name: String) throws {
    guard path.extension == "xcodeproj" else {
      throw ValidationError("'\(name)' must be an Xcode project or JSON project description")
    }
  }
}

private extension Path {
  func findContainedXcodeProjects() throws -> [Path] {
    return try children().filter({ $0.isDirectory && $0.extension == "xcodeproj" })
  }
}

//
//  TargetDescriptionTests.swift
//  MockingbirdTests
//
//  Created by Kiel Gillard on 22/7/21.
//

import XCTest
@testable import MockingbirdGenerator

class ProjectDescriptionDecodingTests: XCTestCase {
  private func assertDecodedTarget(_ decodedTarget: TargetDescription, isEqualTo expectedTarget: TargetDescription) {
    XCTAssertEqual(decodedTarget.name, expectedTarget.name)
    XCTAssertEqual(decodedTarget.c99name, expectedTarget.c99name)
    XCTAssertEqual(decodedTarget.path, expectedTarget.path)
    XCTAssertEqual(decodedTarget.sources, expectedTarget.sources)
    XCTAssertEqual(decodedTarget.dependencies, expectedTarget.dependencies)
  }
  
  enum TestProjectDescription: String {
    case swiftPackageManager = "spm-project-description"
    case generic = "generic-project-description"
    var name: String { return rawValue }
    
    struct LoadingError: LocalizedError {
      let errorDescription: String?
    }
  }
  
  private func loadJSONProjectDescription(_ projectDescription: TestProjectDescription) throws -> Data {
    let testBundle = Bundle(for: type(of: self))
    guard let filePath = testBundle.path(forResource: projectDescription.name,
                                         ofType: "json") else {
      throw TestProjectDescription.LoadingError(
        errorDescription: "No JSON project description named '\(name)'")
    }
    
    guard let json = try? String(contentsOfFile: filePath) else {
      throw TestProjectDescription.LoadingError(
        errorDescription: "Unable to load JSON project description")
    }
    
    guard let jsonData = json.data(using: .utf8) else {
      throw TestProjectDescription.LoadingError(
        errorDescription: "Failed to encode JSON project description to UTF-8")
    }
    
    return jsonData
  }
  
  func testParseSPMDescription() throws {
    let json = try loadJSONProjectDescription(.swiftPackageManager)
    let description = try JSONDecoder().decode(ProjectDescription.self, from: json)
    
    XCTAssertEqual(description.targets.count, 3)
    
    let expectedTestTarget = TargetDescription(name: "FeatureTargetTests",
                                               c99name: "FeatureTargetTests",
                                               type: "test",
                                               path: "Tests/FeatureTargetTests",
                                               sources: [
                                                "ModelTests.swift",
                                                "ControllerTests.swift",
                                                "ViewTests.swift"
                                               ],
                                               dependencies: [
                                                "FeatureTarget"
                                               ])
    
    if let testTarget = description.targets.first(where: { $0.type == expectedTestTarget.type }) {
      assertDecodedTarget(testTarget, isEqualTo: expectedTestTarget)
    } else {
      XCTFail("Did not decode test target.")
    }
    
    let expectedLibraryTarget = TargetDescription(name: "FeatureTarget",
                                                  c99name: "FeatureTarget",
                                                  type: "library",
                                                  path: "Sources/FeatureTarget",
                                                  sources: [
                                                    "Models/Things.swift",
                                                    "Controllers/MasterViewController.swift",
                                                    "Controllers/DetailViewController.swift",
                                                    "Views/DetailView.swift"
                                                  ], dependencies: [
                                                    
                                                  ])
    
    if let libraryTarget = description.targets.first(where: { $0.name == expectedLibraryTarget.name }) {
      assertDecodedTarget(libraryTarget, isEqualTo: expectedLibraryTarget)
    } else {
      XCTFail("Did not decode \(expectedLibraryTarget.name) target.")
    }
    
    let expectedEmptyTarget = TargetDescription(name: "EmptyTarget",
                                                c99name: "EmptyTarget",
                                                type: "library",
                                                path: "Sources/EmptyTarget",
                                                sources: [],
                                                dependencies: [])
    
    if let emptyTarget = description.targets.first(where: { $0.name == expectedEmptyTarget.name }) {
      assertDecodedTarget(emptyTarget, isEqualTo: expectedEmptyTarget)
    } else {
      XCTFail("Did not decode \(expectedEmptyTarget.name) target.")
    }
  }
  
  func testParseGenericDescription() throws {
    let json = try loadJSONProjectDescription(.generic)
    let description = try JSONDecoder().decode(ProjectDescription.self, from: json)
    
    XCTAssertEqual(description.targets.count, 3)
    
    let expectedTestTarget = TargetDescription(name: "FeatureTargetTests",
                                               c99name: "FeatureTargetTests",
                                               type: "test",
                                               path: "Tests/FeatureTargetTests",
                                               sources: [
                                                "ModelTests.swift",
                                                "ControllerTests.swift",
                                                "ViewTests.swift"
                                               ],
                                               dependencies: [
                                                "FeatureTarget"
                                               ])
    
    if let testTarget = description.targets.first(where: { $0.type == expectedTestTarget.type }) {
      assertDecodedTarget(testTarget, isEqualTo: expectedTestTarget)
    } else {
      XCTFail("Did not decode test target.")
    }
    
    let expectedLibraryTarget = TargetDescription(name: "FeatureTarget",
                                                  c99name: "FeatureTarget",
                                                  type: "library",
                                                  path: "Sources/FeatureTarget",
                                                  sources: [
                                                    "Models/Things.swift",
                                                    "Controllers/MasterViewController.swift",
                                                    "Controllers/DetailViewController.swift",
                                                    "Views/DetailView.swift"
                                                  ], dependencies: [
                                                    
                                                  ])
    
    if let libraryTarget = description.targets.first(where: { $0.name == expectedLibraryTarget.name }) {
      assertDecodedTarget(libraryTarget, isEqualTo: expectedLibraryTarget)
    } else {
      XCTFail("Did not decode \(expectedLibraryTarget.name) target.")
    }
    
    let expectedEmptyTarget = TargetDescription(name: "EmptyTarget",
                                                c99name: "EmptyTarget",
                                                type: "library",
                                                path: "Sources/EmptyTarget",
                                                sources: [],
                                                dependencies: [])
    
    if let emptyTarget = description.targets.first(where: { $0.name == expectedEmptyTarget.name }) {
      assertDecodedTarget(emptyTarget, isEqualTo: expectedEmptyTarget)
    } else {
      XCTFail("Did not decode \(expectedEmptyTarget.name) target.")
    }
  }
}

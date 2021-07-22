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
  
  func testParseDescription() throws {
    guard let json = projectDescriptionJSON.data(using: .utf8) else {
      XCTFail("Could not get UTF8 data for project description.")
      return
    }
    
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

// MARK: - JSON Samples

private let projectDescriptionJSON = """
{
  "dependencies":[
    {
      "requirement":{
        "local_package":null
      },
      "url":"../path/to/local/package"
    },
    {
      "name":"Mockingbird",
      "requirement":{
        "range":[
          {
            "lower_bound":"0.16.0",
            "upper_bound":"0.17.0"
          }
        ]
      },
      "url":"https://github.com/birdrides/mockingbird.git"
    }
  ],
  "name":"FeaturePackage",
  "path":"/path/to/FeaturePackage",
  "platforms":[
    {
      "name":"ios",
      "version":"12.0"
    }
  ],
  "products":[
    {
      "name":"Feature",
      "targets":[
        "FeatureTarget"
      ],
      "type":{
        "library":[
          "automatic"
        ]
      }
    }
  ],
  "targets":[
    {
      "c99name":"FeatureTargetTests",
      "module_type":"SwiftTarget",
      "name":"FeatureTargetTests",
      "path":"Tests/FeatureTargetTests",
      "sources":[
        "ModelTests.swift",
        "ControllerTests.swift",
        "ViewTests.swift"
      ],
      "target_dependencies":[
        "FeatureTarget"
      ],
      "type":"test"
    },
    {
      "c99name":"FeatureTarget",
      "module_type":"SwiftTarget",
      "name":"FeatureTarget",
      "path":"Sources/FeatureTarget",
      "product_memberships":[
        "Feature"
      ],
      "resources":[
        {
          "path":"/path/to/FeatureTarget.storyboard",
          "rule":"process"
        }
      ],
      "sources":[
        "Models/Things.swift",
        "Controllers/MasterViewController.swift",
        "Controllers/DetailViewController.swift",
        "Views/DetailView.swift"
      ],
      "target_dependencies":[
        
      ],
      "type":"library"
    },
    {
      "c99name":"EmptyTarget",
      "module_type":"SwiftTarget",
      "name":"EmptyTarget",
      "path":"Sources/EmptyTarget",
      "product_memberships":[
        "Feature"
      ],
      "type":"library"
    }
  ],
  "tools_version":"5.3"
}
"""

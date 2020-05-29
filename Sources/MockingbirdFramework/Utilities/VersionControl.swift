//
//  VersionControl.swift
//  MockingbirdFramework
//
//  Created by Andrew Chang on 8/22/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import XCTest

extension Mock {
  var generatorVersion: Version {
    return Version(shortString: mockMetadata.dictionary["generator_version"] as? String ?? "")
  }
  
  var moduleName: String? {
    return mockMetadata.dictionary["module_name"] as? String
  }
}

func checkVersion(for mock: Mock) {
  let generatorVersion = mock.generatorVersion
  if generatorVersion << mockingbirdVersion {
    let moduleAttribute: String
    if let moduleName = mock.moduleName {
      moduleAttribute = "module '\(moduleName)'"
    } else {
      moduleAttribute = "your project"
    }
    fputs("warning: '\(type(of: mock))' was generated with Mockingbird CLI v\(generatorVersion.shortString) and is at least one major version behind Mockingbird Framework v\(mockingbirdVersion.shortString). Please update Mockingbird CLI and re-generate mocks for \(moduleAttribute).\n", stderr)
  } else if generatorVersion < mockingbirdVersion {
    fputs("warning: '\(type(of: mock))' was generated with Mockingbird CLI v\(generatorVersion.shortString) and is at least one minor version behind Mockingbird Framework v\(mockingbirdVersion.shortString).\n", stderr)
  }
}

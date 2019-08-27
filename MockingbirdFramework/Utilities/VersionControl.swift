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
  
  var generatedDate: Date? {
    guard let rawDate = mockMetadata.dictionary["generated_date"] as? String else { return nil }
    let formatter = DateFormatter.standard()
    return formatter.date(from: rawDate)
  }
  
  var moduleName: String? {
    return mockMetadata.dictionary["module_name"] as? String
  }
}

func checkVersion(for mock: Mock) {
  let dateAttribute: String = {
    if let date = mock.generatedDate {
      let format = DateFormatter()
      format.dateStyle = .short
      format.timeStyle = .none
      return " on \(format.string(from: date))"
    } else {
      return ""
    }
  }()
  
  let generatorVersion = mock.generatorVersion
  if generatorVersion << mockingbirdVersion {
    let moduleAttribute: String
    if let moduleName = mock.moduleName {
      moduleAttribute = "module `\(moduleName)`"
    } else {
      moduleAttribute = "your project"
    }
    fputs("WARNING: `\(type(of: mock))` was generated with Mockingbird CLI v\(generatorVersion.shortString)\(dateAttribute) and is at least one major version behind Mockingbird Framework v\(mockingbirdVersion.shortString). Please update Mockingbird CLI and re-generate mocks for \(moduleAttribute).\n", stderr)
  } else if generatorVersion < mockingbirdVersion {
    fputs("WARNING: `\(type(of: mock))` was generated with Mockingbird CLI v\(generatorVersion.shortString)\(dateAttribute) and is at least one minor version behind Mockingbird Framework v\(mockingbirdVersion.shortString).\n", stderr)
  }
}

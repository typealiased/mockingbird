//
//  ModuleImportCases.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 8/18/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import ObjectiveC
import Foundation // Ignore duplicates (and this comment)

/// This struct will be ignored by the generator.
struct ModuleImportCases {
  let someVariable: Bool
  func someMethod() -> Bool {
    return true
  }
}

import CoreText// Ignore single line comments
import CoreAudio/* Ignore multi-line comments */
import CoreFoundation ; import CoreImage
; import CoreData ;import CoreML
  import CoreMedia

/* Ignore comment before */import CoreVideo
@testable import CoreVideo // Unique because of attribute

import class CoreFoundation.CFArray
import enum CoreText.CTFontUIFontType

/*
 @testable import testable commented out import
 import commented out import
 */

struct ModuleImportCases2 {
  static let multiLineImports = """
  @testable import testable multiline string import
  import multiline string import
  """
  static let singleLineImport = "import singleline string import"
} /* start
 @testable import testable trailing commented out import
 import trailing commented out import
 end */

// @testable import testable single line commented out import
// import single line commented out import

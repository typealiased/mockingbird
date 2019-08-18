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

import class CoreFoundation.CFArray
import enum CoreText.CTFontUIFontType

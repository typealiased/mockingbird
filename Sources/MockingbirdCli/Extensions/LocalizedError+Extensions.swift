//
//  LocalizedError+Extensions.swift
//  MockingbirdCli
//
//  Created by Sterling Hackley on 10/27/19.
//

import Foundation
import SPMUtility

extension ArgumentParserError: LocalizedError {}
extension ArgumentConversionError: LocalizedError {}
extension Generator.MalformedConfiguration: LocalizedError {}

public extension LocalizedError where Self: CustomStringConvertible {
   var errorDescription: String? {
      return description
   }
}

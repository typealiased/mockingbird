//
//  ObjCParameters.swift
//  MockingbirdTestsHost
//
//  Created by typealias on 12/22/21.
//

import AppKit
import Foundation

protocol ObjCParameters {
  func method(value: NSViewController) -> Bool
  func method(optionalValue: NSViewController?) -> Bool
}

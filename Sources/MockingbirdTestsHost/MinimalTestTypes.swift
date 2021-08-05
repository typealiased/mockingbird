//
//  MinimalTestTypes.swift
//  MockingbirdTestsHost
//
//  Created by typealias on 7/25/21.
//

import Foundation

protocol MinimalProtocol {
  var property: String { get set }
  func method(value: String) -> String
}

class MinimalClass {
  var property: String = "super"
  func method(value: String) -> String { return "\(value)-\(property)" }
}

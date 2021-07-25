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

class MimimalClass {
  var property: String = ""
  func method(value: String) -> String { fatalError() }
}

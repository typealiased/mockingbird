//
//  AmbiguousSynthesizedMembers.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 4/18/20.
//

import Foundation

protocol AmbiguousSynthesizedMembers {
  // MARK: Subscript conflicts
  subscript(_ index: String) -> String { get set }
  func getSubscript(_ index: String) -> String
  func setSubscript(_ index: String, newValue: String)
  
  // MARK: Property conflicts
  var property: String { get set }
  func getProperty() -> String
  func setProperty(_ newValue: String)
}

//
//  BuildType.swift
//  MockingbirdCommon
//
//  Created by typealias on 12/30/21.
//

import Foundation

public enum BuildType: Int {
  case framework = 0
  case cli = 1
  case automation = 2
  
  public init(_ stringValue: String?) {
    if let stringValue = stringValue,
       let intValue = Int(stringValue),
       let buildType = BuildType(rawValue: intValue) {
      self = buildType
    } else {
      self = .framework
    }
  }
  
  public static let environmentKey = "MKB_BUILD_TYPE"
}

//
//  DefaultArgumentValues.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 9/2/19.
//

import Foundation

protocol DefaultArgumentValuesProtocol {
  func method(param1: String, param2: [NSObject])
}

extension DefaultArgumentValuesProtocol {
  func method(param1: String = "Hello", param2: [NSObject] = [NSObject]()) {}
}

class DefaultArgumentValuesClass {
  func method(param1: String = "Hello", param2: [NSObject] = [NSObject]()) {}
}

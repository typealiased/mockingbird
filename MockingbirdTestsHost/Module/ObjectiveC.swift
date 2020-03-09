//
//  ObjectiveC.swift
//  MockingbirdModuleTestsHost
//
//  Created by Andrew Chang on 2/29/20.
//

import Foundation

@objc(MKBExternalObjectiveCProtocol)
public protocol ExternalObjectiveCProtocol {
  var variable: Bool { get }
}

//
//  OpaqueTypes.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 9/17/19.
//

import Foundation
import AppKit

class OpaqueViewController: NSViewController {}

public protocol EquatableConformingProtocol: Equatable {}
public protocol HashableConformingProtocol: Hashable {}
public protocol CodableConformingProtocol: Codable {}
public protocol NSObjectProtocolConformingProtocol: Foundation.NSObjectProtocol {}
public protocol NSViewInheritingProtocol: NSView {}
public protocol EquatableCodableConformingProtocol: Equatable, Codable {}

public class EquatableConformingClass: Equatable {
  public static func == (lhs: EquatableConformingClass,
                         rhs: EquatableConformingClass) -> Bool { fatalError() }
}
public class HashableConformingClass: Hashable {
  public static func == (lhs: HashableConformingClass,
                         rhs: HashableConformingClass) -> Bool { fatalError() }
  
  public func hash(into hasher: inout Hasher) { fatalError() }
}
public class CodableConformingClass: Codable {}

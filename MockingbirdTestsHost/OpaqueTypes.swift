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

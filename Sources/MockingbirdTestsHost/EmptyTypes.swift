//
//  EmptyTypes.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 9/15/19.
//

import Foundation

protocol EmptyProtocol {}
class EmptyClass {}

protocol EmptyInheritingProtocol: ChildProtocol {}
class EmptyInheritingClass: Child {}

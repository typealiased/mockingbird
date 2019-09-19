//
//  CompilationDirectives.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 9/18/19.
//

import Foundation

#if DEBUG
protocol DebugCompilationDirectiveProtocol {
  var variable: Bool { get }
}
#else
protocol NotDebugCompilationDirectiveProtocol {
  var variable: Bool { get }
}
#endif

#if DEBUG
protocol OnlyDebugCompilationDirectiveProtocol {
  var variable: Bool { get }
}
#endif

#if !(RELEASE)
extension OnlyDebugCompilationDirectiveProtocol {
  var extensionVariable: Bool { return true }
}
#endif

#if DEBUG
#if !(RELEASE)
protocol NestedCompilationDirectiveProtocol {
  var variable: Bool { get }
}
#endif
#endif

protocol CompilationDirectiveProtocol {
  var variable: Bool { get }
  #if DEBUG
  var debugVariable: Bool { get }
  #else
  var notDebugVariable: Bool { get }
  #endif
  
  #if DEBUG
  var onlyDebugVariable: Bool { get }
  #endif
  
  #if DEBUG
  #if !(RELEASE)
  var nestedVariable: Bool { get }
  #endif
  #endif
  
  func method()
  #if DEBUG
  func debugMethod()
  #else
  func notDebugMethod()
  #endif
  
  #if DEBUG
  func onlyDebugMethod()
  #endif
  
  #if DEBUG
  #if !(RELEASE)
  func nestedMethod()
  #endif
  #endif
}

//
//  CompilationDirectives.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 9/18/19.
//

import Foundation

#if DEBUG
import Foundation
#endif

#if NEVER_TRUE
import InvalidModule
#endif

#if !(DEBUG)
#warning("Testing #warning compilation directive keyword handling")
#endif

#if DEBUG
protocol DebugCompilationDirectiveProtocol {
  var variable: Bool { get }
}
#elseif RELEASE
protocol ReleaseCompilationDirectiveProtocol {
  var variable: Bool { get }
}
#else
protocol DefaultCompilationDirectiveProtocol {
  var variable: Bool { get }
}
#endif

#if DEBUG
protocol OnlyDebugCompilationDirectiveProtocol {
  var variable: Bool { get }
}
#endif

#if !(!(DEBUG))
extension OnlyDebugCompilationDirectiveProtocol {
  var extensionVariable: Bool { return true }
}
#endif

#if DEBUG
#if !(!(DEBUG))
protocol NestedDebugCompilationDirectiveProtocol {
  var variable: Bool { get }
}
#elseif RELEASE
protocol NestedReleaseCompilationDirectiveProtocol {
  var variable: Bool { get }
}
#else
protocol NestedDefaultCompilationDirectiveProtocol {
  var variable: Bool { get }
}
#endif
#endif

protocol CompilationDirectiveProtocol {
  var variable: Bool { get }
  #if DEBUG
  var debugVariable: Bool { get }
  #elseif RELEASE
  var releaseVariable: Bool { get }
  #else
  var defaultVariable: Bool { get }
  #endif
  
  #if DEBUG
  var onlyDebugVariable: Bool { get }
  #endif
  
  #if DEBUG
  #if !(!(DEBUG))
  var nestedDebugVariable: Bool { get }
  #elseif RELEASE
  var nestedReleaseVariable: Bool { get }
  #else
  var nestedDefaultVariable: Bool { get }
  #endif
  #endif
  
  func method()
  #if DEBUG
  func debugMethod()
  #elseif RELEASE
  func releaseMethod()
  #else
  func defaultMethod()
  #endif
  
  #if DEBUG
  func onlyDebugMethod()
  #endif
  
  #if DEBUG
  #if !(!(DEBUG))
  func nestedDebugMethod()
  #elseif RELEASE
  func nestedReleaseMethod()
  #else
  func nestedDefaultMethod()
  #endif
  #endif
}

/*
 #if !(DEBUG)
 */
protocol CommentBlockNotDebugCompilationDirectiveProtocol {
  var variable: Bool { get }
}
/*
 #endif
 */

// #if !(DEBUG)
protocol LineCommentNotDebugCompilationDirectiveProtocol {
  var variable: Bool { get }
}
// #endif

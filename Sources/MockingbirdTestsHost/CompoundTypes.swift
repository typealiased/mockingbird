//
//  CompoundTypes.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 9/2/19.
//

import Foundation

protocol ArrayTypes {
  func method(param1: [NSObject], param2: [Foundation.NSObject])
  func method() -> [NSObject]
  func method() -> [Foundation.NSObject]
  func method() -> ([NSObject], [Foundation.NSObject])
  func method()
    -> ([NSObject], [Foundation.NSObject])
    -> ([NSObject], [Foundation.NSObject])
  func methodWithParameterLabels()
    -> (_ param1: [NSObject], _ param2: [Foundation.NSObject])
    -> ([NSObject], [Foundation.NSObject])
  
  func explicitMethod(param1: Array<NSObject>, param2: Array<Foundation.NSObject>)
  func explicitMethod() -> Array<NSObject>
  func explicitMethod() -> Array<Foundation.NSObject>
  func explicitMethod() -> (Array<NSObject>, Array<Foundation.NSObject>)
  func explicitMethod()
    -> (Array<NSObject>, Array<Foundation.NSObject>)
    -> (Array<NSObject>, Array<Foundation.NSObject>)
  func explicitMethodWithParameterLabels()
    -> (_ param1: Array<NSObject>, _ param2: Array<Foundation.NSObject>)
    -> (Array<NSObject>, Array<Foundation.NSObject>)
  
  var variable: [NSObject] { get }
  var anotherVariable: [Foundation.NSObject] { get }
  
  var explicitVariable: Array<NSObject> { get }
  var explicitAnotherVariable: Array<Foundation.NSObject> { get }
  
  var optionalVariable: [NSObject?] { get }
  var optionalAnotherVariable: [Foundation.NSObject?] { get }
  
  var optionalExplicitVariable: Array<NSObject?> { get }
  var optionalExplicitAnotherVariable: Array<Foundation.NSObject?> { get }
}

struct DictionaryKey: Hashable {}
typealias URL = DictionaryKey
protocol DictionaryTypes {
  func method(param1: [URL: NSObject], param2: [Foundation.URL: Foundation.NSObject])
  func method() -> [URL: NSObject]
  func method() -> [Foundation.URL: Foundation.NSObject]
  func method() -> ([URL: NSObject], [Foundation.URL: Foundation.NSObject])
  func method()
    -> ([URL: NSObject], [Foundation.URL: Foundation.NSObject])
    -> ([URL: NSObject], [Foundation.URL: Foundation.NSObject])
  func methodWithParameterLabels()
    -> (_ param1: [URL: NSObject], _ param2: [Foundation.URL: Foundation.NSObject])
    -> ([URL: NSObject], [Foundation.URL: Foundation.NSObject])
  
  func explicitMethod(param1: Dictionary<URL, NSObject>,
                      param2: Dictionary<Foundation.URL, Foundation.NSObject>)
  func explicitMethod() -> Dictionary<URL, NSObject>
  func explicitMethod() -> Dictionary<Foundation.URL, Foundation.NSObject>
  func explicitMethod()
    -> (Dictionary<URL, NSObject>, Dictionary<Foundation.URL, Foundation.NSObject>)
  func explicitMethod()
    -> (Dictionary<URL, NSObject>, Dictionary<Foundation.URL, Foundation.NSObject>)
    -> (Dictionary<URL, NSObject>, Dictionary<Foundation.URL, Foundation.NSObject>)
  func explicitMethodWithParameterLabels()
    -> (
    _ param1: Dictionary<URL, NSObject>,
    _ param2: Dictionary<Foundation.URL, Foundation.NSObject>)
    -> (Dictionary<URL, NSObject>, Dictionary<Foundation.URL, Foundation.NSObject>)
  
  var variable: [URL: NSObject] { get }
  var anotherVariable: [Foundation.URL: Foundation.NSObject] { get }
  
  var explicitVariable: Dictionary<URL, NSObject> { get }
  var explicitAnotherVariable: Dictionary<Foundation.URL, Foundation.NSObject> { get }
  
  var optionalVariable: [URL: NSObject?] { get }
  var optionalAnotherVariable: [Foundation.URL: Foundation.NSObject?] { get }
  
  var optionalExplicitVariable: Dictionary<URL, NSObject?> { get }
  var optionalExplicitAnotherVariable: Dictionary<Foundation.URL, Foundation.NSObject?> { get }
}

protocol TupleTypes {
  func method(param1: (URL, NSObject), param2: (Foundation.URL, Foundation.NSObject))
  func method() -> (URL, NSObject)
  func method() -> (Foundation.URL, Foundation.NSObject)
  func method() -> ((URL, NSObject), (Foundation.URL, Foundation.NSObject))
  func method()
    -> ((URL, NSObject), (Foundation.URL, Foundation.NSObject))
    -> ((URL, NSObject), (Foundation.URL, Foundation.NSObject))
  func methodWithParameterLabels()
    -> (_ param1: (URL, NSObject), _ param2: (Foundation.URL, Foundation.NSObject))
    -> ((URL, NSObject), (Foundation.URL, Foundation.NSObject))
  
  func labeledMethod(
    param1: (a: URL, b: NSObject, (URL, NSObject)),
    param2: (a: Foundation.URL, b: Foundation.NSObject, (Foundation.URL, Foundation.NSObject)))
  func labeledMethod()
    -> (a: URL, b: NSObject, (URL, NSObject))
  func labeledMethod()
    -> (a: Foundation.URL, b: Foundation.NSObject, (Foundation.URL, Foundation.NSObject))
  func labeledMethod()
    -> (
    (a: URL, b: NSObject, (URL, NSObject)),
    (a: Foundation.URL, b: Foundation.NSObject,
    (Foundation.URL, Foundation.NSObject)))
  func labeledMethod()
    -> (
    (a: URL, b: NSObject, (URL, NSObject)),
    (a: Foundation.URL, b: Foundation.NSObject,
    (Foundation.URL, Foundation.NSObject)))
    -> (
    (a: URL, b: NSObject, (URL, NSObject)),
    (a: Foundation.URL, b: Foundation.NSObject,
    (Foundation.URL, Foundation.NSObject)))
  func labeledMethodWithParameterLabels()
    -> (
    _ param1: (a: URL, b: NSObject, (URL, NSObject)),
    _ param2: (a: Foundation.URL, b: Foundation.NSObject, (Foundation.URL, Foundation.NSObject)))
    -> (
    (a: URL, b: NSObject, (URL, NSObject)),
    (a: Foundation.URL, b: Foundation.NSObject,
    (Foundation.URL, Foundation.NSObject)))
  
  var variable: (URL, NSObject) { get }
  var anotherVariable: (Foundation.URL, Foundation.NSObject) { get }
  
  var labeledVariable: (a: URL, b: NSObject, (URL, NSObject)) { get }
  var labeledAnotherVariable: (
    a: Foundation.URL,
    b: Foundation.NSObject,
    (Foundation.URL, Foundation.NSObject)) { get }
  
  var optionalVariable: (URL?, NSObject?) { get }
  var optionalAnotherVariable: (Foundation.URL?, Foundation.NSObject?) { get }
  
  var optionalLabeledVariable: (a: URL?, b: NSObject?, (URL?, NSObject?)?) { get }
  var optionalLabeledAnotherVariable: (
    a: Foundation.URL,
    b: Foundation.NSObject,
    (Foundation.URL?, Foundation.NSObject?)?) { get }
}

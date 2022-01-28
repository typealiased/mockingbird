import Foundation

@objc protocol ObjCProtocol: Foundation.NSObjectProtocol {
  @objc func trivial()
  @objc func parameterizedReturning(param: String) -> Bool
  
  @objc var property: Bool { get }
  @objc var readwriteProperty: Bool { get set }
  
  // It’s possible to define Obj-C protocols with overloaded subscript requirements, but it can
  // never be implemented in Swift as the compiler will complain about the conflicting selectors.
  // @objc subscript(param: Int) -> Int { get set }
  
  // MARK: Optional
  
  @objc optional func optionalTrivial()
  @objc optional func optionalParameterizedReturning(param: String) -> Bool
  
  @objc optional var optionalProperty: Bool { get }
  @objc optional var optionalReadwriteProperty: Bool { get set }
  
  @objc optional subscript(param: Int) -> Bool { get set }
}

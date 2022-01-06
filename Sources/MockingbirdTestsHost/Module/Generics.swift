import Foundation
import AppKit

public class ReferencedGenericClass<T> {}
public class ReferencedGenericClassWithConstraints<S: Sequence> where S.Element: Hashable {}

public protocol ExternalClassConstrainedProtocol: NSViewController {}

open class InitializableOpenClass {
  open var openVariable = true
  public var publicVariable = true
  var internalVariable = true
  public init() {}
}
public protocol InitializableOpenClassConstrainedProtocol: InitializableOpenClass {}

open class OpenClass {
  open var openVariable = true
  public var publicVariable = true
  var internalVariable = true
}
public protocol UninitializableOpenClassConstrainedProtocol: OpenClass {}

public class PublicClass {
  open var openVariable = true
  public var publicVariable = true
  var internalVariable = true
}
public protocol UnmockablePublicClassConstrainedProtocol: PublicClass {}

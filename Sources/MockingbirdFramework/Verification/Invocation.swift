import Foundation

/// Attributes selectors to a specific member type.
@objc(MKBSelectorType) public enum SelectorType: UInt, CustomStringConvertible {
  case method
  case getter
  case setter
  case subscriptGetter
  case subscriptSetter
  
  public var description: String {
    switch self {
    case .method: return "method"
    case .setter: return "setter"
    case .getter: return "getter"
    case .subscriptGetter: return "subscript getter"
    case .subscriptSetter: return "subscript setter"
    }
  }
}

/// Mocks create invocations when receiving calls to methods or member methods.
protocol Invocation: CustomStringConvertible {
  var selectorName: String { get }
  var selectorType: SelectorType { get }
  var arguments: [ArgumentMatcher] { get }
  var returnType: ObjectIdentifier { get }
  var uid: UInt { get }
  
  /// Selector name without tickmark escaping.
  var unwrappedSelectorName: String { get }
  /// Mockable declaration identifier, e.g. `someMethod`, `getSomeProperty`.
  var declarationIdentifier: String { get }
  
  /// If the current invocation referrs to a property getter, convert it to the equivalent setter.
  /// - Warning: This method is not available for invocations on mocked Objective-C types.
  func toSetter() -> Self?
}

extension Invocation {
  // Avoids making `Invocation` a generic protocol.
  func isEqual(to rhs: Invocation) -> Bool {
    guard arguments.count == rhs.arguments.count else { return false }
    guard returnType == rhs.returnType else { return false }
    for (index, argument) in arguments.enumerated() {
      if argument != rhs.arguments[index] { return false }
    }
    return true
  }
}

struct SwiftInvocation: Invocation {
  let selectorName: String
  let setterSelectorName: String?
  let selectorType: SelectorType
  let arguments: [ArgumentMatcher]
  let returnType: ObjectIdentifier
  let uid = MonotonicIncreasingIndex.getIndex()

  init(selectorName: String,
       setterSelectorName: String? = nil,
       selectorType: SelectorType,
       arguments: [ArgumentMatcher],
       returnType: ObjectIdentifier) {
    // Handle argument matchers in dynamic declaration contexts.
    var resolvedArguments = arguments
    if let recorder = InvocationRecorder.sharedRecorder {
      for i in 0..<resolvedArguments.count {
        guard let matcher = recorder.getFacadeValue(at: i, argumentsCount: resolvedArguments.count)
                as? ArgumentMatcher else { continue }
        resolvedArguments[i] = matcher
      }
    }
    
    self.selectorName = selectorName
    self.setterSelectorName = setterSelectorName
    self.selectorType = selectorType
    self.arguments = resolvedArguments
    self.returnType = returnType
  }
  
  var unwrappedSelectorName: String {
    return selectorName.replacingOccurrences(of: "`", with: "")
  }
  
  var declarationIdentifier: String {
    let unwrappedSelectorName = self.unwrappedSelectorName
    guard selectorType != .method else {
      let endIndex = unwrappedSelectorName.firstIndex(of: "(") ?? unwrappedSelectorName.endIndex
      return String(unwrappedSelectorName[..<endIndex])
    }
    
    // Extract the property name.
    return unwrappedSelectorName
      .components(separatedBy: ".")
      .dropLast()
      .joined(separator: ".")
  }

  var description: String {
    guard !arguments.isEmpty else { return "'\(unwrappedSelectorName)'" }
    let matchers = arguments.map({ String(describing: $0) }).joined(separator: ", ")
    return "'\(unwrappedSelectorName)' with arguments [\(matchers)]"
  }
  
  enum Constants {
    // Keep this in sync with `MockingbirdGenerator.VariableTemplate.getterName`
    static let getterSuffix = ".getter"
    // Keep this in sync with `MockingbirdGenerator.VariableTemplate.setterName`
    static let setterSuffix = ".setter"
  }
  
  func toSetter() -> Self? {
    guard let selectorName = setterSelectorName else { return nil }
    let matcher = ArgumentMatcher(description: "any()",
                                  declaration: "any()",
                                  priority: .high) { return true }
    return Self(selectorName: selectorName,
                setterSelectorName: setterSelectorName,
                selectorType: .setter,
                arguments: [matcher],
                returnType: ObjectIdentifier(Void.self))
  }
}

/// An invocation recieved by an Objective-C.
@objc(MKBObjCInvocation) public class ObjCInvocation: NSObject, Invocation {
  let selectorName: String
  let setterSelectorName: String?
  let selectorType: SelectorType
  let arguments: [ArgumentMatcher]
  let returnType: ObjectIdentifier
  let objcReturnType: String
  let uid = MonotonicIncreasingIndex.getIndex()
  
  @objc public required init(selectorName: String,
                             setterSelectorName: String?,
                             selectorType: SelectorType,
                             arguments: [ArgumentMatcher],
                             objcReturnType: String) {
    self.selectorName = selectorName
    self.setterSelectorName = setterSelectorName
    self.selectorType = selectorType
    self.arguments = arguments
    self.returnType = ObjectIdentifier(Any?.self) // The return type as seen by Swift.
    self.objcReturnType = objcReturnType
  }
  
  var unwrappedSelectorName: String { return selectorName }
  var declarationIdentifier: String {
    return String(selectorName.split(separator: ":").first ?? "")
  }
  
  override public var description: String {
    guard !arguments.isEmpty else { return "'\(unwrappedSelectorName)'" }
    let matchers = arguments.map({ String(describing: $0) }).joined(separator: ", ")
    return "'\(unwrappedSelectorName)' with arguments [\(matchers)]"
  }
  
  func toSetter() -> Self? {
    guard let selectorName = setterSelectorName else { return nil }
    let matcher = ArgumentMatcher(description: "any()",
                                  declaration: "any()",
                                  priority: .high) { return true }
    return Self(selectorName: selectorName,
                setterSelectorName: selectorName,
                selectorType: .setter,
                arguments: [matcher],
                objcReturnType: objcReturnType)
  }
}

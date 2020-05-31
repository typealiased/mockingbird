//
//  Sequence.swift
//  MockingbirdFramework
//
//  Created by Andrew Chang on 5/31/20.
//

import Foundation

/// The sequence behavior when the number of invocations exceeds the number of values provided.
enum SequenceType {
  /// Use the last value.
  case lastValue
  /// Return to the first value in the sequence.
  case looping
  /// Stop returning values.
  case finite
  
  func nextIndex(_ index: Int, count: Int) -> Int {
    guard index+1 >= count else { return index + 1 }
    switch self {
    case .lastValue:
      return count-1
    case .looping:
      return 0
    case .finite:
      return count
    }
  }
}

/// Stub a sequence of values.
///
/// Provide one or more values which will be returned sequentially for each invocation. The last
/// value will be used if the number of invocations is greater than the number of values provided.
///
///     given(bird.getName())
///       .willReturn(sequence(of: "Ryan", "Sterling"))
///
///     print(bird.name)  // Prints "Ryan"
///     print(bird.name)  // Prints "Sterling"
///     print(bird.name)  // Prints "Sterling"
///
/// - Parameter values: A sequence of values to stub.
public func sequence<DeclarationType: Declaration, InvocationType, ReturnType>(
  of values: ReturnType...
) -> ImplementationProvider<DeclarationType, InvocationType, ReturnType> {
  return sequence(of: values, type: .lastValue)
}

/// Stub a sequence of implementations.
///
/// Provide one or more implementations which will be returned sequentially for each invocation. The
/// last implementation will be used if the number of invocations is greater than the number of
/// implementations provided.
///
///     given(bird.getName()).willReturn(sequence(of: {
///       return Bool.random() ? "Ryan" : "Meisters"
///     }, {
///       return Bool.random() ? "Sterling" : "Hackley"
///     }))
///
///     print(bird.name)  // Prints "Ryan"
///     print(bird.name)  // Prints "Sterling"
///     print(bird.name)  // Prints "Hackley"
///
/// - Parameter implementations: A sequence of implementations to stub.
public func sequence<DeclarationType: Declaration, InvocationType, ReturnType>(
  of implementations: InvocationType...
) -> ImplementationProvider<DeclarationType, InvocationType, ReturnType> {
  return sequence(of: implementations, type: .lastValue)
}

/// Stub a looping sequence of values.
///
/// Provide one or more values which will be returned sequentially for each invocation. The sequence
/// will loop from the beginning if the number of invocations is greater than the number of values
/// provided.
///
///     given(bird.getName())
///       .willReturn(loopingSequence(of: "Ryan", "Sterling"))
///
///     print(bird.name)  // Prints "Ryan"
///     print(bird.name)  // Prints "Sterling"
///     print(bird.name)  // Prints "Ryan"
///     print(bird.name)  // Prints "Sterling"
///
/// - Parameter values: A sequence of values to stub.
public func loopingSequence<DeclarationType: Declaration, InvocationType, ReturnType>(
  of values: ReturnType...
) -> ImplementationProvider<DeclarationType, InvocationType, ReturnType> {
  return sequence(of: values, type: .looping)
}

/// Stub a looping sequence of implementations.
///
/// Provide one or more implementations which will be returned sequentially for each invocation. The
/// sequence will loop from the beginning if the number of invocations is greater than the number of
/// implementations provided.
///
///     given(bird.getName()).willReturn(loopingSequence(of: {
///       return Bool.random() ? "Ryan" : "Meisters"
///     }, {
///       return Bool.random() ? "Sterling" : "Hackley"
///     }))
///
///     print(bird.name)  // Prints "Ryan"
///     print(bird.name)  // Prints "Sterling"
///     print(bird.name)  // Prints "Meisters"
///     print(bird.name)  // Prints "Hackley"
///
/// - Parameter implementations: A sequence of implementations to stub.
public func loopingSequence<DeclarationType: Declaration, InvocationType, ReturnType>(
  of implementations: InvocationType...
) -> ImplementationProvider<DeclarationType, InvocationType, ReturnType> {
  return sequence(of: implementations, type: .looping)
}

/// Stub a finite sequence of values.
///
/// Provide one or more values which will be returned sequentially for each invocation. The stub
/// will be invalidated if the number of invocations is greater than the number of values provided.
///
///     given(bird.getName())
///       .willReturn(finiteSequence(of: "Ryan", "Sterling"))
///
///     print(bird.name)  // Prints "Ryan"
///     print(bird.name)  // Prints "Sterling"
///     print(bird.name)  // Error: Missing stubbed implementation
///
/// - Parameter values: A sequence of values to stub.
public func finiteSequence<DeclarationType: Declaration, InvocationType, ReturnType>(
  of values: ReturnType...
) -> ImplementationProvider<DeclarationType, InvocationType, ReturnType> {
  return sequence(of: values, type: .finite)
}

/// Stub a finite sequence of implementations.
///
/// Provide one or more implementations which will be returned sequentially for each invocation. The
/// stub will be invalidated if the number of invocations is greater than the number of
/// implementations provided.
///
///     given(bird.getName()).willReturn(finiteSequence(of: {
///       return Bool.random() ? "Ryan" : "Meisters"
///     }, {
///       return Bool.random() ? "Sterling" : "Hackley"
///     }))
///
///     print(bird.name)  // Prints "Ryan"
///     print(bird.name)  // Prints "Sterling"
///     print(bird.name)  // Error: Missing stubbed implementation
///
/// - Parameter implementations: A sequence of implementations to stub.
public func finiteSequence<DeclarationType: Declaration, InvocationType, ReturnType>(
  of implementations: InvocationType...
) -> ImplementationProvider<DeclarationType, InvocationType, ReturnType> {
  return sequence(of: implementations, type: .finite)
}

/// Stub a sequence of values.
///
/// - Parameter values: A list of values to stub.
func sequence<DeclarationType: Declaration, InvocationType, ReturnType>(
  of values: [ReturnType],
  type: SequenceType
) -> ImplementationProvider<DeclarationType, InvocationType, ReturnType> {
  var index = 0
  let implementation: () -> ReturnType = {
    let value = values[index]
    index = type.nextIndex(index, count: values.count)
    return value
  }
  let availability: () -> Bool = {
    return values.get(index) != nil
  }
  return ImplementationProvider(implementation: implementation,
                                availability: availability,
                                callback: nil)
}

/// Stub a sequence of implementations.
///
/// - Parameter implementations: A list of implementations to stub.
func sequence<DeclarationType: Declaration, InvocationType, ReturnType>(
  of implementations: [InvocationType],
  type: SequenceType
) -> ImplementationProvider<DeclarationType, InvocationType, ReturnType> {
  var index = 0
  let implementationCreator: () -> InvocationType? = {
    let implementation = implementations.get(index)
    index = type.nextIndex(index, count: implementations.count)
    return implementation
  }
  return ImplementationProvider(implementationCreator: implementationCreator, callback: nil)
}

/// Stubs a variable getter to return the last value received by the setter.
///
/// - Parameter initial: The initial value to return.
public func lastSetValue<DeclarationType: PropertyGetterDeclaration, InvocationType, ReturnType>(
  initial: ReturnType
) -> ImplementationProvider<DeclarationType, InvocationType, ReturnType> {
  var currentValue = initial
  let implementation: () -> ReturnType = { return currentValue }
  let callback = { (stub: StubbingContext.Stub, context: StubbingContext) in
    guard let setterInvocation = stub.invocation.toSetter() else { return }
    let setterImplementation = { (newValue: ReturnType) -> Void in
      currentValue = newValue
    }
    _ = context.swizzle(setterInvocation, with: { setterImplementation })
  }
  return ImplementationProvider(implementation: implementation, callback: callback)
}

import Foundation

/// An intermediate object used for stubbing Objective-C declarations returned by `given`.
///
/// Stubbed implementations are type erased to allow Swift to apply arguments with minimal type
/// information. See `StubbingContext+ObjCReturnValue` for more context.
public class DynamicStubbingManager<ReturnType>:
  StubbingManager<AnyDeclaration, Any?, ReturnType> {
  
  /// Stub a mocked method or property by returning a single value.
  ///
  /// Stubbing allows you to define custom behavior for mocks to perform.
  ///
  /// ```swift
  /// given(bird.doMethod()).willReturn(someValue)
  /// given(bird.property).willReturn(someValue)
  /// ```
  ///
  /// Match exact or wildcard argument values when stubbing methods with parameters. Stubs added
  /// later have a higher precedence, so add stubs with specific matchers last.
  ///
  /// ```swift
  /// given(bird.canChirp(volume: any())).willReturn(true)     // Any volume
  /// given(bird.canChirp(volume: notNil())).willReturn(true)  // Any non-nil volume
  /// given(bird.canChirp(volume: 10)).willReturn(true)        // Volume = 10
  /// ```
  ///
  /// - Parameter value: A stubbed value to return.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  override public func willReturn(_ value: ReturnType) -> Self {
    return addImplementation({ () -> Any in
      return value as Any
    })
  }
  
  /// Stub a mocked method that throws with an error.
  ///
  /// Stubbing allows you to define custom behavior for mocks to perform. Methods that throw or
  /// rethrow errors can be stubbed with a throwable object.
  ///
  /// ```swift
  /// struct BirdError: Error {}
  /// given(bird.throwingMethod()).willThrow(BirdError())
  /// ```
  ///
  /// - Note: Methods overloaded by return type should chain `returning` with `willThrow` to
  /// disambiguate the mocked declaration.
  ///
  /// - Warning: It’s undefined behavior to stub throwing an error on a dynamically mocked method
  /// that does not actually throw.
  ///
  /// - Parameter error: A stubbed error object to throw.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func willThrow(_ error: Error) -> Self {
    return addImplementation({ () throws -> Any in
      throw error
    })
  }
  
  // MARK: - Non-throwing
  
  /// Stub a mocked method or property with a closure implementation.
  ///
  /// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
  ///
  /// ```swift
  /// given(bird.canChirp(volume: any()))
  ///   .will { volume in
  ///     return volume < 42
  ///   }
  /// ```
  ///
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will(
    _ implementation: @escaping () -> ReturnType
  ) -> Self {
    return addImplementation({
      implementation() as Any
    })
  }

  /// Stub a mocked method or property with a closure implementation.
  ///
  /// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
  ///
  /// ```swift
  /// given(bird.canChirp(volume: any()))
  ///   .will { volume in
  ///     return volume < 42
  ///   }
  /// ```
  ///
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will<P0>(
    _ implementation: @escaping (P0) -> ReturnType
  ) -> Self {
    return addImplementation({
      (p0: Any?) in
      implementation(p0 as! P0) as Any
    })
  }
  
  /// Stub a mocked method or property with a closure implementation.
  ///
  /// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
  ///
  /// ```swift
  /// given(bird.canChirp(volume: any()))
  ///   .will { volume in
  ///     return volume < 42
  ///   }
  /// ```
  ///
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will<P0,P1>(
    _ implementation: @escaping (P0,P1) -> ReturnType
  ) -> Self {
    return addImplementation({
      (p0: Any?, p1: Any?) in
      implementation(p0 as! P0, p1 as! P1) as Any
    })
  }
  
  /// Stub a mocked method or property with a closure implementation.
  ///
  /// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
  ///
  /// ```swift
  /// given(bird.canChirp(volume: any()))
  ///   .will { volume in
  ///     return volume < 42
  ///   }
  /// ```
  ///
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will<P0,P1,P2>(
    _ implementation: @escaping (P0,P1,P2) -> ReturnType
  ) -> Self {
    return addImplementation({
      (p0: Any?, p1: Any?, p2: Any?) in
      implementation(p0 as! P0, p1 as! P1, p2 as! P2) as Any
    })
  }
  
  /// Stub a mocked method or property with a closure implementation.
  ///
  /// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
  ///
  /// ```swift
  /// given(bird.canChirp(volume: any()))
  ///   .will { volume in
  ///     return volume < 42
  ///   }
  /// ```
  ///
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will<P0,P1,P2,P3>(
    _ implementation: @escaping (P0,P1,P2,P3) -> ReturnType
  ) -> Self {
    return addImplementation({
      (p0: Any?, p1: Any?, p2: Any?, p3: Any?) in
      implementation(p0 as! P0, p1 as! P1, p2 as! P2, p3 as! P3) as Any
    })
  }
  
  /// Stub a mocked method or property with a closure implementation.
  ///
  /// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
  ///
  /// ```swift
  /// given(bird.canChirp(volume: any()))
  ///   .will { volume in
  ///     return volume < 42
  ///   }
  /// ```
  ///
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will<P0,P1,P2,P3,P4>(
    _ implementation: @escaping (P0,P1,P2,P3,P4) -> ReturnType
  ) -> Self {
    return addImplementation({
      (p0: Any?, p1: Any?, p2: Any?, p3: Any?, p4: Any?) in
      implementation(p0 as! P0, p1 as! P1, p2 as! P2, p3 as! P3, p4 as! P4) as Any
    })
  }
  
  /// Stub a mocked method or property with a closure implementation.
  ///
  /// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
  ///
  /// ```swift
  /// given(bird.canChirp(volume: any()))
  ///   .will { volume in
  ///     return volume < 42
  ///   }
  /// ```
  ///
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will<P0,P1,P2,P3,P4,P5>(
    _ implementation: @escaping (P0,P1,P2,P3,P4,P5) -> ReturnType
  ) -> Self {
    return addImplementation({
      (p0: Any?, p1: Any?, p2: Any?, p3: Any?, p4: Any?, p5: Any?) in
      implementation(p0 as! P0, p1 as! P1, p2 as! P2, p3 as! P3, p4 as! P4, p5 as! P5) as Any
    })
  }
  
  /// Stub a mocked method or property with a closure implementation.
  ///
  /// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
  ///
  /// ```swift
  /// given(bird.canChirp(volume: any()))
  ///   .will { volume in
  ///     return volume < 42
  ///   }
  /// ```
  ///
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will<P0,P1,P2,P3,P4,P5,P6>(
    _ implementation: @escaping (P0,P1,P2,P3,P4,P5,P6) -> ReturnType
  ) -> Self {
    return addImplementation({
      (p0: Any?, p1: Any?, p2: Any?, p3: Any?, p4: Any?, p5: Any?, p6: Any?) in
      implementation(p0 as! P0, p1 as! P1, p2 as! P2, p3 as! P3, p4 as! P4, p5 as! P5, p6 as! P6)
        as Any
    })
  }
  
  /// Stub a mocked method or property with a closure implementation.
  ///
  /// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
  ///
  /// ```swift
  /// given(bird.canChirp(volume: any()))
  ///   .will { volume in
  ///     return volume < 42
  ///   }
  /// ```
  ///
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will<P0,P1,P2,P3,P4,P5,P6,P7>(
    _ implementation: @escaping (P0,P1,P2,P3,P4,P5,P6,P7) -> ReturnType
  ) -> Self {
    return addImplementation({
      (p0: Any?, p1: Any?, p2: Any?, p3: Any?, p4: Any?, p5: Any?, p6: Any?, p7: Any?) in
       implementation(p0 as! P0, p1 as! P1, p2 as! P2, p3 as! P3, p4 as! P4, p5 as! P5, p6 as! P6,
                      p7 as! P7) as Any
    })
  }
  
  /// Stub a mocked method or property with a closure implementation.
  ///
  /// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
  ///
  /// ```swift
  /// given(bird.canChirp(volume: any()))
  ///   .will { volume in
  ///     return volume < 42
  ///   }
  /// ```
  ///
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will<P0,P1,P2,P3,P4,P5,P6,P7,P8>(
    _ implementation: @escaping (P0,P1,P2,P3,P4,P5,P6,P7,P8) -> ReturnType
  ) -> Self {
    return addImplementation({
      (p0: Any?, p1: Any?, p2: Any?, p3: Any?, p4: Any?, p5: Any?, p6: Any?, p7: Any?, p8: Any?) in
       implementation(p0 as! P0, p1 as! P1, p2 as! P2, p3 as! P3, p4 as! P4, p5 as! P5, p6 as! P6,
                      p7 as! P7, p8 as! P8) as Any
    })
  }
  
  /// Stub a mocked method or property with a closure implementation.
  ///
  /// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
  ///
  /// ```swift
  /// given(bird.canChirp(volume: any()))
  ///   .will { volume in
  ///     return volume < 42
  ///   }
  /// ```
  ///
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will<P0,P1,P2,P3,P4,P5,P6,P7,P8,P9>(
    _ implementation: @escaping (P0,P1,P2,P3,P4,P5,P6,P7,P8,P9) -> ReturnType
  ) -> Self {
    return addImplementation({
      (p0: Any?, p1: Any?, p2: Any?, p3: Any?, p4: Any?, p5: Any?, p6: Any?, p7: Any?, p8: Any?,
       p9: Any?) in
      implementation(p0 as! P0, p1 as! P1, p2 as! P2, p3 as! P3, p4 as! P4, p5 as! P5, p6 as! P6,
                     p7 as! P7, p8 as! P8, p9 as! P9) as Any
    })
  }
  
  // MARK: - Throwing
  
  /// Stub a mocked method or property with a closure implementation.
  ///
  /// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
  ///
  /// ```swift
  /// given(bird.canChirp(volume: any()))
  ///   .will { volume in
  ///     return volume < 42
  ///   }
  /// ```
  ///
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will(
    _ implementation: @escaping () throws -> ReturnType
  ) -> Self {
    return addImplementation({
      try implementation() as Any
    })
  }

  /// Stub a mocked method or property with a closure implementation.
  ///
  /// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
  ///
  /// ```swift
  /// given(bird.canChirp(volume: any()))
  ///   .will { volume in
  ///     return volume < 42
  ///   }
  /// ```
  ///
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will<P0>(
    _ implementation: @escaping (P0) throws -> ReturnType
  ) -> Self {
    return addImplementation({
      (p0: Any?) in
      try implementation(p0 as! P0) as Any
    })
  }
  
  /// Stub a mocked method or property with a closure implementation.
  ///
  /// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
  ///
  /// ```swift
  /// given(bird.canChirp(volume: any()))
  ///   .will { volume in
  ///     return volume < 42
  ///   }
  /// ```
  ///
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will<P0,P1>(
    _ implementation: @escaping (P0,P1) throws -> ReturnType
  ) -> Self {
    return addImplementation({
      (p0: Any?, p1: Any?) in
      try implementation(p0 as! P0, p1 as! P1) as Any
    })
  }
  
  /// Stub a mocked method or property with a closure implementation.
  ///
  /// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
  ///
  /// ```swift
  /// given(bird.canChirp(volume: any()))
  ///   .will { volume in
  ///     return volume < 42
  ///   }
  /// ```
  ///
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will<P0,P1,P2>(
    _ implementation: @escaping (P0,P1,P2) throws -> ReturnType
  ) -> Self {
    return addImplementation({
      (p0: Any?, p1: Any?, p2: Any?) in
      try implementation(p0 as! P0, p1 as! P1, p2 as! P2) as Any
    })
  }
  
  /// Stub a mocked method or property with a closure implementation.
  ///
  /// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
  ///
  /// ```swift
  /// given(bird.canChirp(volume: any()))
  ///   .will { volume in
  ///     return volume < 42
  ///   }
  /// ```
  ///
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will<P0,P1,P2,P3>(
    _ implementation: @escaping (P0,P1,P2,P3) throws -> ReturnType
  ) -> Self {
    return addImplementation({
      (p0: Any?, p1: Any?, p2: Any?, p3: Any?) in
      try implementation(p0 as! P0, p1 as! P1, p2 as! P2, p3 as! P3) as Any
    })
  }
  
  /// Stub a mocked method or property with a closure implementation.
  ///
  /// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
  ///
  /// ```swift
  /// given(bird.canChirp(volume: any()))
  ///   .will { volume in
  ///     return volume < 42
  ///   }
  /// ```
  ///
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will<P0,P1,P2,P3,P4>(
    _ implementation: @escaping (P0,P1,P2,P3,P4) throws -> ReturnType
  ) -> Self {
    return addImplementation({
      (p0: Any?, p1: Any?, p2: Any?, p3: Any?, p4: Any?) in
      try implementation(p0 as! P0, p1 as! P1, p2 as! P2, p3 as! P3, p4 as! P4) as Any
    })
  }
  
  /// Stub a mocked method or property with a closure implementation.
  ///
  /// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
  ///
  /// ```swift
  /// given(bird.canChirp(volume: any()))
  ///   .will { volume in
  ///     return volume < 42
  ///   }
  /// ```
  ///
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will<P0,P1,P2,P3,P4,P5>(
    _ implementation: @escaping (P0,P1,P2,P3,P4,P5) throws -> ReturnType
  ) -> Self {
    return addImplementation({
      (p0: Any?, p1: Any?, p2: Any?, p3: Any?, p4: Any?, p5: Any?) in
      try implementation(p0 as! P0, p1 as! P1, p2 as! P2, p3 as! P3, p4 as! P4, p5 as! P5) as Any
    })
  }
  
  /// Stub a mocked method or property with a closure implementation.
  ///
  /// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
  ///
  /// ```swift
  /// given(bird.canChirp(volume: any()))
  ///   .will { volume in
  ///     return volume < 42
  ///   }
  /// ```
  ///
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will<P0,P1,P2,P3,P4,P5,P6>(
    _ implementation: @escaping (P0,P1,P2,P3,P4,P5,P6) throws -> ReturnType
  ) -> Self {
    return addImplementation({
      (p0: Any?, p1: Any?, p2: Any?, p3: Any?, p4: Any?, p5: Any?, p6: Any?) in
      try implementation(p0 as! P0, p1 as! P1, p2 as! P2, p3 as! P3, p4 as! P4, p5 as! P5,
                         p6 as! P6) as Any
    })
  }
  
  /// Stub a mocked method or property with a closure implementation.
  ///
  /// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
  ///
  /// ```swift
  /// given(bird.canChirp(volume: any()))
  ///   .will { volume in
  ///     return volume < 42
  ///   }
  /// ```
  ///
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will<P0,P1,P2,P3,P4,P5,P6,P7>(
    _ implementation: @escaping (P0,P1,P2,P3,P4,P5,P6,P7) throws -> ReturnType
  ) -> Self {
    return addImplementation({
      (p0: Any?, p1: Any?, p2: Any?, p3: Any?, p4: Any?, p5: Any?, p6: Any?, p7: Any?) in
       try implementation(p0 as! P0, p1 as! P1, p2 as! P2, p3 as! P3, p4 as! P4, p5 as! P5,
                          p6 as! P6, p7 as! P7) as Any
    })
  }
  
  /// Stub a mocked method or property with a closure implementation.
  ///
  /// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
  ///
  /// given(bird.canChirp(volume: any()))
  ///   .will { volume in
  ///     return volume < 42
  ///   }
  ///
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will<P0,P1,P2,P3,P4,P5,P6,P7,P8>(
    _ implementation: @escaping (P0,P1,P2,P3,P4,P5,P6,P7,P8) throws -> ReturnType
  ) -> Self {
    return addImplementation({
      (p0: Any?, p1: Any?, p2: Any?, p3: Any?, p4: Any?, p5: Any?, p6: Any?, p7: Any?, p8: Any?) in
       try implementation(p0 as! P0, p1 as! P1, p2 as! P2, p3 as! P3, p4 as! P4, p5 as! P5,
                          p6 as! P6, p7 as! P7, p8 as! P8) as Any
    })
  }
  
  /// Stub a mocked method or property with a closure implementation.
  ///
  /// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
  ///
  /// given(bird.canChirp(volume: any()))
  ///   .will { volume in
  ///     return volume < 42
  ///   }
  ///
  /// - Parameter implementation: A closure implementation stub to evaluate.
  /// - Returns: The current stubbing manager which can be used to chain additional stubs.
  @discardableResult
  public func will<P0,P1,P2,P3,P4,P5,P6,P7,P8,P9>(
    _ implementation: @escaping (P0,P1,P2,P3,P4,P5,P6,P7,P8,P9) throws -> ReturnType
  ) -> Self {
    return addImplementation({
      (p0: Any?, p1: Any?, p2: Any?, p3: Any?, p4: Any?, p5: Any?, p6: Any?, p7: Any?, p8: Any?,
       p9: Any?) in
      try implementation(p0 as! P0, p1 as! P1, p2 as! P2, p3 as! P3, p4 as! P4, p5 as! P5,
                         p6 as! P6, p7 as! P7, p8 as! P8, p9 as! P9) as Any
    })
  }
}

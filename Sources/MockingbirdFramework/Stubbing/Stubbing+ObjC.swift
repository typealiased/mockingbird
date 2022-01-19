import Foundation

/// Stub a mocked Objective-C method or property by returning a single value.
///
/// Stubbing allows you to define custom behavior for mocks to perform.
///
/// ```swift
/// given(bird.doMethod()) ~> someValue
/// given(bird.property) ~> someValue
/// ```
///
/// Match exact or wildcard argument values when stubbing methods with parameters. Stubs added
/// later have a higher precedence, so add stubs with specific matchers last.
///
/// ```swift
/// given(bird.canChirp(volume: any())) ~> true     // Any volume
/// given(bird.canChirp(volume: notNil())) ~> true  // Any non-nil volume
/// given(bird.canChirp(volume: 10)) ~> true        // Volume = 10
/// ```
///
/// - Parameters:
///   - manager: A stubbing manager containing declaration and argument metadata for stubbing.
///   - implementation: A stubbed value to return.
public func ~> <ReturnType>(
  manager: DynamicStubbingManager<ReturnType>,
  implementation: @escaping @autoclosure () -> ReturnType
) {
  manager.addImplementation({
    implementation() as Any
  })
}


// MARK: - Non-throwing

/// Stub a mocked Objective-C method or property with a closure implementation.
///
/// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
///
/// ```swift
/// given(bird.canChirp(volume: any())) ~> { volume in
///   return volume < 42
/// }
/// ```
///
/// - Parameters:
///   - manager: A stubbing manager containing declaration and argument metadata for stubbing.
///   - implementation: A closure implementation stub to evaluate.
public func ~> <ReturnType>(
  manager: DynamicStubbingManager<ReturnType>,
  implementation: @escaping () -> ReturnType
) {
  manager.addImplementation({
    implementation() as Any
  })
}

/// Stub a mocked Objective-C method or property with a closure implementation.
///
/// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
///
/// ```swift
/// given(bird.canChirp(volume: any())) ~> { volume in
///   return volume < 42
/// }
/// ```
///
/// - Parameters:
///   - manager: A stubbing manager containing declaration and argument metadata for stubbing.
///   - implementation: A closure implementation stub to evaluate.
public func ~> <P0,ReturnType>(
  manager: DynamicStubbingManager<ReturnType>,
  implementation: @escaping (P0) -> ReturnType
) {
  manager.addImplementation({
    (p0: Any?) in
    implementation(p0 as! P0) as Any
  })
}

/// Stub a mocked Objective-C method or property with a closure implementation.
///
/// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
///
/// ```swift
/// given(bird.canChirp(volume: any())) ~> { volume in
///   return volume < 42
/// }
/// ```
///
/// - Parameters:
///   - manager: A stubbing manager containing declaration and argument metadata for stubbing.
///   - implementation: A closure implementation stub to evaluate.
public func ~> <P0,P1,ReturnType>(
  manager: DynamicStubbingManager<ReturnType>,
  implementation: @escaping (P0,P1) -> ReturnType
) {
  manager.addImplementation({
    (p0: Any?, p1: Any?) in
    implementation(p0 as! P0, p1 as! P1) as Any
  })
}

/// Stub a mocked Objective-C method or property with a closure implementation.
///
/// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
///
/// ```swift
/// given(bird.canChirp(volume: any())) ~> { volume in
///   return volume < 42
/// }
/// ```
///
/// - Parameters:
///   - manager: A stubbing manager containing declaration and argument metadata for stubbing.
///   - implementation: A closure implementation stub to evaluate.
public func ~> <P0,P1,P2,ReturnType>(
  manager: DynamicStubbingManager<ReturnType>,
  implementation: @escaping (P0,P1,P2) -> ReturnType
) {
  manager.addImplementation({
    (p0: Any?, p1: Any?, p2: Any?) in
    implementation(p0 as! P0, p1 as! P1, p2 as! P2) as Any
  })
}

/// Stub a mocked Objective-C method or property with a closure implementation.
///
/// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
///
/// ```swift
/// given(bird.canChirp(volume: any())) ~> { volume in
///   return volume < 42
/// }
/// ```
///
/// - Parameters:
///   - manager: A stubbing manager containing declaration and argument metadata for stubbing.
///   - implementation: A closure implementation stub to evaluate.
public func ~> <P0,P1,P2,P3,ReturnType>(
  manager: DynamicStubbingManager<ReturnType>,
  implementation: @escaping (P0,P1,P2,P3) -> ReturnType
) {
  manager.addImplementation({
    (p0: Any?, p1: Any?, p2: Any?, p3: Any?) in
    implementation(p0 as! P0, p1 as! P1, p2 as! P2, p3 as! P3) as Any
  })
}

/// Stub a mocked Objective-C method or property with a closure implementation.
///
/// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
///
/// ```swift
/// given(bird.canChirp(volume: any())) ~> { volume in
///   return volume < 42
/// }
/// ```
///
/// - Parameters:
///   - manager: A stubbing manager containing declaration and argument metadata for stubbing.
///   - implementation: A closure implementation stub to evaluate.
public func ~> <P0,P1,P2,P3,P4,ReturnType>(
  manager: DynamicStubbingManager<ReturnType>,
  implementation: @escaping (P0,P1,P2,P3,P4) -> ReturnType
) {
  manager.addImplementation({
    (p0: Any?, p1: Any?, p2: Any?, p3: Any?, p4: Any?) in
    implementation(p0 as! P0, p1 as! P1, p2 as! P2, p3 as! P3, p4 as! P4) as Any
  })
}

/// Stub a mocked Objective-C method or property with a closure implementation.
///
/// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
///
/// ```swift
/// given(bird.canChirp(volume: any())) ~> { volume in
///   return volume < 42
/// }
/// ```
///
/// - Parameters:
///   - manager: A stubbing manager containing declaration and argument metadata for stubbing.
///   - implementation: A closure implementation stub to evaluate.
public func ~> <P0,P1,P2,P3,P4,P5,ReturnType>(
  manager: DynamicStubbingManager<ReturnType>,
  implementation: @escaping (P0,P1,P2,P3,P4,P5) -> ReturnType
) {
  manager.addImplementation({
    (p0: Any?, p1: Any?, p2: Any?, p3: Any?, p4: Any?, p5: Any?) in
    implementation(p0 as! P0, p1 as! P1, p2 as! P2, p3 as! P3, p4 as! P4, p5 as! P5) as Any
  })
}

/// Stub a mocked Objective-C method or property with a closure implementation.
///
/// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
///
/// ```swift
/// given(bird.canChirp(volume: any())) ~> { volume in
///   return volume < 42
/// }
/// ```
///
/// - Parameters:
///   - manager: A stubbing manager containing declaration and argument metadata for stubbing.
///   - implementation: A closure implementation stub to evaluate.
public func ~> <P0,P1,P2,P3,P4,P5,P6,ReturnType>(
  manager: DynamicStubbingManager<ReturnType>,
  implementation: @escaping (P0,P1,P2,P3,P4,P5,P6) -> ReturnType
) {
  manager.addImplementation({
    (p0: Any?, p1: Any?, p2: Any?, p3: Any?, p4: Any?, p5: Any?, p6: Any?) in
    implementation(p0 as! P0, p1 as! P1, p2 as! P2, p3 as! P3, p4 as! P4, p5 as! P5, p6 as! P6)
      as Any
  })
}

/// Stub a mocked Objective-C method or property with a closure implementation.
///
/// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
///
/// ```swift
/// given(bird.canChirp(volume: any())) ~> { volume in
///   return volume < 42
/// }
/// ```
///
/// - Parameters:
///   - manager: A stubbing manager containing declaration and argument metadata for stubbing.
///   - implementation: A closure implementation stub to evaluate.
public func ~> <P0,P1,P2,P3,P4,P5,P6,P7,ReturnType>(
  manager: DynamicStubbingManager<ReturnType>,
  implementation: @escaping (P0,P1,P2,P3,P4,P5,P6,P7) -> ReturnType
) {
  manager.addImplementation({
    (p0: Any?, p1: Any?, p2: Any?, p3: Any?, p4: Any?, p5: Any?, p6: Any?, p7: Any?) in
    implementation(p0 as! P0, p1 as! P1, p2 as! P2, p3 as! P3, p4 as! P4, p5 as! P5, p6 as! P6,
                   p7 as! P7) as Any
  })
}

/// Stub a mocked Objective-C method or property with a closure implementation.
///
/// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
///
/// ```swift
/// given(bird.canChirp(volume: any())) ~> { volume in
///   return volume < 42
/// }
/// ```
///
/// - Parameters:
///   - manager: A stubbing manager containing declaration and argument metadata for stubbing.
///   - implementation: A closure implementation stub to evaluate.
public func ~> <P0,P1,P2,P3,P4,P5,P6,P7,P8,ReturnType>(
  manager: DynamicStubbingManager<ReturnType>,
  implementation: @escaping (P0,P1,P2,P3,P4,P5,P6,P7,P8) -> ReturnType
) {
  manager.addImplementation({
    (p0: Any?, p1: Any?, p2: Any?, p3: Any?, p4: Any?, p5: Any?, p6: Any?, p7: Any?, p8: Any?) in
    implementation(p0 as! P0, p1 as! P1, p2 as! P2, p3 as! P3, p4 as! P4, p5 as! P5, p6 as! P6,
                   p7 as! P7, p8 as! P8) as Any
  })
}

/// Stub a mocked Objective-C method or property with a closure implementation.
///
/// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
///
/// ```swift
/// given(bird.canChirp(volume: any())) ~> { volume in
///   return volume < 42
/// }
/// ```
///
/// - Parameters:
///   - manager: A stubbing manager containing declaration and argument metadata for stubbing.
///   - implementation: A closure implementation stub to evaluate.
public func ~> <P0,P1,P2,P3,P4,P5,P6,P7,P8,P9,ReturnType>(
  manager: DynamicStubbingManager<ReturnType>,
  implementation: @escaping (P0,P1,P2,P3,P4,P5,P6,P7,P8,P9) -> ReturnType
) {
  manager.addImplementation({
    (p0: Any?, p1: Any?, p2: Any?, p3: Any?, p4: Any?, p5: Any?, p6: Any?, p7: Any?, p8: Any?,
     p9: Any?) in
    implementation(p0 as! P0, p1 as! P1, p2 as! P2, p3 as! P3, p4 as! P4, p5 as! P5, p6 as! P6,
                   p7 as! P7, p8 as! P8, p9 as! P9) as Any
  })
}


// MARK: - Throwing

/// Stub a mocked Objective-C method or property with a closure implementation.
///
/// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
///
/// ```swift
/// given(bird.canChirp(volume: any())) ~> { volume in
///   return volume < 42
/// }
/// ```
///
/// - Parameters:
///   - manager: A stubbing manager containing declaration and argument metadata for stubbing.
///   - implementation: A closure implementation stub to evaluate.
public func ~> <ReturnType>(
  manager: DynamicStubbingManager<ReturnType>,
  implementation: @escaping () throws -> ReturnType
) {
  manager.addImplementation({
    try implementation() as Any
  })
}

/// Stub a mocked Objective-C method or property with a closure implementation.
///
/// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
///
/// ```swift
/// given(bird.canChirp(volume: any())) ~> { volume in
///   return volume < 42
/// }
/// ```
///
/// - Parameters:
///   - manager: A stubbing manager containing declaration and argument metadata for stubbing.
///   - implementation: A closure implementation stub to evaluate.
public func ~> <P0,ReturnType>(
  manager: DynamicStubbingManager<ReturnType>,
  implementation: @escaping (P0) throws -> ReturnType
) {
  manager.addImplementation({
    (p0: Any?) in
    try implementation(p0 as! P0) as Any
  })
}

/// Stub a mocked Objective-C method or property with a closure implementation.
///
/// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
///
/// ```swift
/// given(bird.canChirp(volume: any())) ~> { volume in
///   return volume < 42
/// }
/// ```
///
/// - Parameters:
///   - manager: A stubbing manager containing declaration and argument metadata for stubbing.
///   - implementation: A closure implementation stub to evaluate.
public func ~> <P0,P1,ReturnType>(
  manager: DynamicStubbingManager<ReturnType>,
  implementation: @escaping (P0,P1) throws -> ReturnType
) {
  manager.addImplementation({
    (p0: Any?, p1: Any?) in
    try implementation(p0 as! P0, p1 as! P1) as Any
  })
}

/// Stub a mocked Objective-C method or property with a closure implementation.
///
/// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
///
/// ```swift
/// given(bird.canChirp(volume: any())) ~> { volume in
///   return volume < 42
/// }
/// ```
///
/// - Parameters:
///   - manager: A stubbing manager containing declaration and argument metadata for stubbing.
///   - implementation: A closure implementation stub to evaluate.
public func ~> <P0,P1,P2,ReturnType>(
  manager: DynamicStubbingManager<ReturnType>,
  implementation: @escaping (P0,P1,P2) throws -> ReturnType
) {
  manager.addImplementation({
    (p0: Any?, p1: Any?, p2: Any?) in
    try implementation(p0 as! P0, p1 as! P1, p2 as! P2) as Any
  })
}

/// Stub a mocked Objective-C method or property with a closure implementation.
///
/// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
///
/// ```swift
/// given(bird.canChirp(volume: any())) ~> { volume in
///   return volume < 42
/// }
/// ```
///
/// - Parameters:
///   - manager: A stubbing manager containing declaration and argument metadata for stubbing.
///   - implementation: A closure implementation stub to evaluate.
public func ~> <P0,P1,P2,P3,ReturnType>(
  manager: DynamicStubbingManager<ReturnType>,
  implementation: @escaping (P0,P1,P2,P3) throws -> ReturnType
) {
  manager.addImplementation({
    (p0: Any?, p1: Any?, p2: Any?, p3: Any?) in
    try implementation(p0 as! P0, p1 as! P1, p2 as! P2, p3 as! P3) as Any
  })
}

/// Stub a mocked Objective-C method or property with a closure implementation.
///
/// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
///
/// ```swift
/// given(bird.canChirp(volume: any())) ~> { volume in
///   return volume < 42
/// }
/// ```
///
/// - Parameters:
///   - manager: A stubbing manager containing declaration and argument metadata for stubbing.
///   - implementation: A closure implementation stub to evaluate.
public func ~> <P0,P1,P2,P3,P4,ReturnType>(
  manager: DynamicStubbingManager<ReturnType>,
  implementation: @escaping (P0,P1,P2,P3,P4) throws -> ReturnType
) {
  manager.addImplementation({
    (p0: Any?, p1: Any?, p2: Any?, p3: Any?, p4: Any?) in
    try implementation(p0 as! P0, p1 as! P1, p2 as! P2, p3 as! P3, p4 as! P4) as Any
  })
}

/// Stub a mocked Objective-C method or property with a closure implementation.
///
/// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
///
/// ```swift
/// given(bird.canChirp(volume: any())) ~> { volume in
///   return volume < 42
/// }
/// ```
///
/// - Parameters:
///   - manager: A stubbing manager containing declaration and argument metadata for stubbing.
///   - implementation: A closure implementation stub to evaluate.
public func ~> <P0,P1,P2,P3,P4,P5,ReturnType>(
  manager: DynamicStubbingManager<ReturnType>,
  implementation: @escaping (P0,P1,P2,P3,P4,P5) throws -> ReturnType
) {
  manager.addImplementation({
    (p0: Any?, p1: Any?, p2: Any?, p3: Any?, p4: Any?, p5: Any?) in
    try implementation(p0 as! P0, p1 as! P1, p2 as! P2, p3 as! P3, p4 as! P4, p5 as! P5) as Any
  })
}

/// Stub a mocked Objective-C method or property with a closure implementation.
///
/// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
///
/// ```swift
/// given(bird.canChirp(volume: any())) ~> { volume in
///   return volume < 42
/// }
/// ```
///
/// - Parameters:
///   - manager: A stubbing manager containing declaration and argument metadata for stubbing.
///   - implementation: A closure implementation stub to evaluate.
public func ~> <P0,P1,P2,P3,P4,P5,P6,ReturnType>(
  manager: DynamicStubbingManager<ReturnType>,
  implementation: @escaping (P0,P1,P2,P3,P4,P5,P6) throws -> ReturnType
) {
  manager.addImplementation({
    (p0: Any?, p1: Any?, p2: Any?, p3: Any?, p4: Any?, p5: Any?, p6: Any?) in
    try implementation(p0 as! P0, p1 as! P1, p2 as! P2, p3 as! P3, p4 as! P4, p5 as! P5, p6 as! P6)
      as Any
  })
}

/// Stub a mocked Objective-C method or property with a closure implementation.
///
/// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
///
/// ```swift
/// given(bird.canChirp(volume: any())) ~> { volume in
///   return volume < 42
/// }
/// ```
///
/// - Parameters:
///   - manager: A stubbing manager containing declaration and argument metadata for stubbing.
///   - implementation: A closure implementation stub to evaluate.
public func ~> <P0,P1,P2,P3,P4,P5,P6,P7,ReturnType>(
  manager: DynamicStubbingManager<ReturnType>,
  implementation: @escaping (P0,P1,P2,P3,P4,P5,P6,P7) throws -> ReturnType
) {
  manager.addImplementation({
    (p0: Any?, p1: Any?, p2: Any?, p3: Any?, p4: Any?, p5: Any?, p6: Any?, p7: Any?) in
    try implementation(p0 as! P0, p1 as! P1, p2 as! P2, p3 as! P3, p4 as! P4, p5 as! P5, p6 as! P6,
                       p7 as! P7) as Any
  })
}

/// Stub a mocked Objective-C method or property with a closure implementation.
///
/// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
///
/// ```swift
/// given(bird.canChirp(volume: any())) ~> { volume in
///   return volume < 42
/// }
/// ```
///
/// - Parameters:
///   - manager: A stubbing manager containing declaration and argument metadata for stubbing.
///   - implementation: A closure implementation stub to evaluate.
public func ~> <P0,P1,P2,P3,P4,P5,P6,P7,P8,ReturnType>(
  manager: DynamicStubbingManager<ReturnType>,
  implementation: @escaping (P0,P1,P2,P3,P4,P5,P6,P7,P8) throws -> ReturnType
) {
  manager.addImplementation({
    (p0: Any?, p1: Any?, p2: Any?, p3: Any?, p4: Any?, p5: Any?, p6: Any?, p7: Any?, p8: Any?) in
    try implementation(p0 as! P0, p1 as! P1, p2 as! P2, p3 as! P3, p4 as! P4, p5 as! P5, p6 as! P6,
                       p7 as! P7, p8 as! P8) as Any
  })
}

/// Stub a mocked Objective-C method or property with a closure implementation.
///
/// Use a closure to implement stubs that contain logic, interact with arguments, or throw errors.
///
/// ```swift
/// given(bird.canChirp(volume: any())) ~> { volume in
///   return volume < 42
/// }
/// ```
///
/// - Parameters:
///   - manager: A stubbing manager containing declaration and argument metadata for stubbing.
///   - implementation: A closure implementation stub to evaluate.
public func ~> <P0,P1,P2,P3,P4,P5,P6,P7,P8,P9,ReturnType>(
  manager: DynamicStubbingManager<ReturnType>,
  implementation: @escaping (P0,P1,P2,P3,P4,P5,P6,P7,P8,P9) throws -> ReturnType
) {
  manager.addImplementation({
    (p0: Any?, p1: Any?, p2: Any?, p3: Any?, p4: Any?, p5: Any?, p6: Any?, p7: Any?, p8: Any?,
     p9: Any?) in
    try implementation(p0 as! P0, p1 as! P1, p2 as! P2, p3 as! P3, p4 as! P4, p5 as! P5, p6 as! P6,
                       p7 as! P7, p8 as! P8, p9 as! P9) as Any
  })
}


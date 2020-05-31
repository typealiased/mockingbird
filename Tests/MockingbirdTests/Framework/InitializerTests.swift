//
//  InitializerTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 9/5/19.
//

import XCTest
import Mockingbird
@testable import MockingbirdTestsHost

class InitializerTests: XCTestCase {
  
  // MARK: Standard initialization
  
  var initializerClass: InitializerClassMock!
  var initializerProtocol: InitializerProtocolMock!
  
  func testInitializerClass() {
    initializerClass = mock(InitializerClass.self).initialize()
    initializerClass = mock(InitializerClass.self).initialize(param: true)
    initializerClass = mock(InitializerClass.self).initialize(param: 1)
    initializerClass = try! mock(InitializerClass.self).initialize(param: "hello world")
    initializerClass = mock(InitializerClass.self).initialize(param: Optional<String>(nil))
  }
  
  func testInitializerProtocol() {
    initializerProtocol = mock(InitializerProtocol.self)
  }
  
  
  // MARK: Empty type initialization
  
  var emptyProtocol: EmptyProtocolMock!
  var emptyClass: EmptyClassMock!
  var emptyInheritingProtocol: EmptyInheritingProtocolMock!
  var emptyInheritingClass: EmptyInheritingClassMock!
  
  func testEmptyTypeInitialization() {
    emptyProtocol = mock(EmptyProtocol.self)
    emptyClass = mock(EmptyClass.self)
  }
  
  func testEmptyInheritingTypeInitialization() {
    emptyInheritingProtocol = mock(EmptyInheritingProtocol.self)
    emptyInheritingClass = mock(EmptyInheritingClass.self)
  }
  
  
  // MARK: Class only protocol initialization
  
  var deprecatedClassOnlyProtocol: DeprecatedClassOnlyProtocolMock!
  var deprecatedClassOnlyProtocolWithInheritance: DeprecatedClassOnlyProtocolWithInheritanceMock!
  var classOnlyProtocol: ClassOnlyProtocolMock!
  var classOnlyProtocolWithInheritance: ClassOnlyProtocolWithInheritanceMock!
  var openClassConstrainedProtocol: ConformingInitializableOpenClassConstrainedProtocolMock!
  var nsObjectProtocolConformingProtocol: NSObjectProtocolConformingProtocolMock!
  var initializableClassOnlyProtocol: InitializableClassOnlyProtocolMock!
  var initializableClassOnlyProtocolWithInheritedInitializer: InitializableClassOnlyProtocolWithInheritedInitializerMock!
  
  func testDeprecatedClassOnlyProtocolInitialization() {
    deprecatedClassOnlyProtocol = mock(DeprecatedClassOnlyProtocol.self)
    deprecatedClassOnlyProtocolWithInheritance = mock(DeprecatedClassOnlyProtocolWithInheritance.self)
  }
  
  func testClassOnlyProtocolInitialization() {
    classOnlyProtocol = mock(ClassOnlyProtocol.self)
    classOnlyProtocolWithInheritance = mock(ClassOnlyProtocolWithInheritance.self)
    openClassConstrainedProtocol =
      mock(ConformingInitializableOpenClassConstrainedProtocol.self).initialize()
    nsObjectProtocolConformingProtocol = mock(NSObjectProtocolConformingProtocol.self).initialize()
    initializableClassOnlyProtocol =
      mock(InitializableClassOnlyProtocol.self).initialize(param1: true, param2: 42)
    initializableClassOnlyProtocolWithInheritedInitializer =
      mock(InitializableClassOnlyProtocolWithInheritedInitializer.self).initialize(param: true)
    initializableClassOnlyProtocolWithInheritedInitializer =
      mock(InitializableClassOnlyProtocolWithInheritedInitializer.self).initialize(param: 42)
  }
  
  
  // MARK: - Inferred mock type initialization
  
  func testInferredClassMockTypeInitialization() {
    let child = mock(Child.self)
    (child as Child).childTrivialInstanceMethod()
    verify(child.childTrivialInstanceMethod()).wasCalled()
  }
  
  func testInferredProtocolMockTypeInitialization() {
    let child = mock(ChildProtocol.self)
    (child as ChildProtocol).childTrivialInstanceMethod()
    verify(child.childTrivialInstanceMethod()).wasCalled()
  }
  
  func testInferredClassOnlyProtocolMockTypeInitialization() {
    let classOnlyProtocol = mock(ClassOnlyProtocol.self)
    given(classOnlyProtocol.getVariable()) ~> true
    XCTAssertTrue((classOnlyProtocol as ClassOnlyProtocol).variable)
    verify(classOnlyProtocol.getVariable()).wasCalled()
  }
}


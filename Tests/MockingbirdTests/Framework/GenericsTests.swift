//
//  GenericsTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 7/26/20.
//

import Mockingbird
import XCTest
@testable import MockingbirdTestsHost

class GenericsTests: BaseTestCase {
  
  struct EquatableType: Equatable {
    let value: Int
  }
  
  struct HashableType: Hashable {
    let value: Int
  }
  
  var protocolMock: AssociatedTypeProtocolMock<EquatableType, HashableType>!
  func call<T: MockingbirdTestsHost.AssociatedTypeProtocol>(
    _ collaborator: T,
    with object: T.EquatableType
  ) -> T.EquatableType where T.EquatableType == EquatableType {
    return collaborator.methodUsingEquatableTypeWithReturn(equatable: object)
  }
  func call<T: MockingbirdTestsHost.AssociatedTypeProtocol>(
    _ collaborator: T.Type,
    with object: T.EquatableType
  ) -> T.EquatableType where T.EquatableType == EquatableType {
    return collaborator.methodUsingEquatableTypeWithReturn(equatable: object)
  }
  
  var classMock: AssociatedTypeGenericImplementerMock<EquatableType, [EquatableType]>!
  var classInstance: AssociatedTypeGenericImplementer<EquatableType, [EquatableType]> {
    return classMock
  }
  
  let staticTestQueue = DispatchQueue(label: "co.bird.mockingbird.tests")
  
  override func setUp() {
    protocolMock = mock(AssociatedTypeProtocol<EquatableType, HashableType>.self)
    classMock = mock(AssociatedTypeGenericImplementer<EquatableType, [EquatableType]>.self)
  }
  
  // MARK: - Associated type protocol
  
  func testProtocolMock_stubParameterizedReturningInstanceMethod_wildcardMatcher() {
    given(protocolMock.methodUsingEquatableTypeWithReturn(equatable: any())).will { return $0 }
    XCTAssertEqual(call(protocolMock, with: EquatableType(value: 1)),
                   EquatableType(value: 1))
    verify(protocolMock.methodUsingEquatableTypeWithReturn(equatable: any())).wasCalled()
  }
  
  func testProtocolMock_stubParameterizedReturningInstanceMethod_exactMatcher() {
    given(protocolMock.methodUsingEquatableTypeWithReturn(equatable: EquatableType(value: 1)))
      .will { return $0 }
    given(protocolMock.methodUsingEquatableTypeWithReturn(equatable: EquatableType(value: 2)))
      .willReturn(EquatableType(value: 42))
    XCTAssertEqual(call(protocolMock, with: EquatableType(value: 2)),
                   EquatableType(value: 42))
    verify(protocolMock.methodUsingEquatableTypeWithReturn(equatable: EquatableType(value: 1)))
      .wasNeverCalled()
    verify(protocolMock.methodUsingEquatableTypeWithReturn(equatable: EquatableType(value: 2)))
      .wasCalled()
  }
  
  func testProtocolMock_stubParameterizedReturningStaticMethod_wildcardMatcher() {
    staticTestQueue.sync {
      reset(type(of: protocolMock).staticMock)
      
      given(type(of: protocolMock).methodUsingEquatableTypeWithReturn(equatable: any()))
        .will { return $0 }
      XCTAssertEqual(call(type(of: protocolMock), with: EquatableType(value: 1)),
                     EquatableType(value: 1))
      verify(type(of: protocolMock).methodUsingEquatableTypeWithReturn(equatable: any()))
        .wasCalled()
    }
  }
  
  func testProtocolMock_stubParameterizedReturningStaticMethod_exactMatcher() {
    staticTestQueue.sync {
      reset(protocolMock)
      
      given(type(of: protocolMock)
        .methodUsingEquatableTypeWithReturn(equatable: EquatableType(value: 1)))
        .will { return $0 }
      given(type(of: protocolMock)
        .methodUsingEquatableTypeWithReturn(equatable: EquatableType(value: 2)))
        .willReturn(EquatableType(value: 42))
      XCTAssertEqual(call(type(of: protocolMock), with: EquatableType(value: 2)),
                     EquatableType(value: 42))
      verify(type(of: protocolMock)
        .methodUsingEquatableTypeWithReturn(equatable: EquatableType(value: 1)))
        .wasNeverCalled()
      verify(type(of: protocolMock)
        .methodUsingEquatableTypeWithReturn(equatable: EquatableType(value: 2)))
        .wasCalled()
    }
  }
  
  // MARK: - Generic class
  
  func testClassMock_stubParameterizedReturningInstanceMethod_wildcardMatcher() {
    given(classMock.methodUsingEquatableTypeWithReturn(equatable: any())).will { return $0 }
    XCTAssertEqual(
      classInstance.methodUsingEquatableTypeWithReturn(equatable: EquatableType(value: 1)),
      EquatableType(value: 1)
    )
    verify(classMock.methodUsingEquatableTypeWithReturn(equatable: any())).wasCalled()
  }
  
  func testClassMock_stubParameterizedReturningInstanceMethod_exactMatcher() {
    given(classMock.methodUsingEquatableTypeWithReturn(equatable: EquatableType(value: 1)))
      .will { return $0 }
    given(classMock.methodUsingEquatableTypeWithReturn(equatable: EquatableType(value: 2)))
      .willReturn(EquatableType(value: 42))
    XCTAssertEqual(
      classInstance.methodUsingEquatableTypeWithReturn(equatable: EquatableType(value: 2)),
      EquatableType(value: 42)
    )
    verify(classMock.methodUsingEquatableTypeWithReturn(equatable: EquatableType(value: 1)))
      .wasNeverCalled()
    verify(classMock.methodUsingEquatableTypeWithReturn(equatable: EquatableType(value: 2)))
      .wasCalled()
  }
  
  func testClassMock_stubParameterizedReturningClassMethod_wildcardMatcher() {
    staticTestQueue.sync {
      reset(type(of: classMock).staticMock)
      
      given(type(of: classMock).methodUsingEquatableTypeWithReturn(equatable: any()))
        .will { return $0 }
      XCTAssertEqual(
        type(of: classMock).methodUsingEquatableTypeWithReturn(equatable: EquatableType(value: 1)),
        EquatableType(value: 1)
      )
      verify(type(of: classMock).methodUsingEquatableTypeWithReturn(equatable: any())).wasCalled()
    }
  }
  
  func testClassMock_stubParameterizedReturningClassMethod_exactMatcher() {
    staticTestQueue.sync {
      reset(type(of: classMock).staticMock)
      
      given(type(of: classMock)
        .methodUsingEquatableTypeWithReturn(equatable: EquatableType(value: 1)))
        .will { return $0 }
      given(type(of: classMock)
        .methodUsingEquatableTypeWithReturn(equatable: EquatableType(value: 2)))
        .willReturn(EquatableType(value: 42))
      XCTAssertEqual(
        type(of: classMock).methodUsingEquatableTypeWithReturn(equatable: EquatableType(value: 2)),
        EquatableType(value: 42)
      )
      verify(type(of: classMock)
        .methodUsingEquatableTypeWithReturn(equatable: EquatableType(value: 1)))
        .wasNeverCalled()
      verify(type(of: classMock)
        .methodUsingEquatableTypeWithReturn(equatable: EquatableType(value: 2)))
        .wasCalled()
    }
  }
}

//
//  DefaultValueProviderTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 4/11/20.
//

import XCTest
import Mockingbird
@testable import MockingbirdTestsHost

class DefaultValueProviderTests: BaseTestCase {
  
  var concreteMock: FakeableTypeReferencerMock!
  var concreteInstance: FakeableTypeReferencer { return concreteMock }
  
  override func setUp() {
    concreteMock = mock(FakeableTypeReferencer.self)
  }
  
  // MARK: - Single registration
  
  func testFakeableClass() {
    let fakeClassInstance = FakeableClass(param: "hello-world")
    let valueProvider = ValueProvider().register(fakeClassInstance, for: FakeableClass.self)
    useDefaultValues(from: valueProvider, on: concreteMock)
    
    XCTAssertTrue(concreteInstance.fakeableClass() === fakeClassInstance)
    verify(concreteMock.fakeableClass()).wasCalled()
  }
  
  func testFakeableGenericClass() {
    let fakeGenericClassInstance = FakeableGenericClass(param: true)
    let valueProvider = ValueProvider()
      .register(fakeGenericClassInstance, for: FakeableGenericClass<Bool>.self)
    useDefaultValues(from: valueProvider, on: concreteMock)
    
    let genericClassReference: FakeableGenericClass<Bool> = concreteInstance.fakeableGenericClass()
    XCTAssertTrue(genericClassReference === fakeGenericClassInstance)
    verify(concreteMock.fakeableGenericClass())
      .returning(FakeableGenericClass<Bool>.self)
      .wasCalled()
  }
  
  func testFakeableProtocol() {
    class ConcreteFakeableProtocol: FakeableProtocol {}
    let fakeProtocolInstance = ConcreteFakeableProtocol()
    let valueProvider = ValueProvider().register(fakeProtocolInstance, for: FakeableProtocol.self)
    useDefaultValues(from: valueProvider, on: concreteMock)
    
    let concreteProtocolReference =
      (concreteInstance.fakeableProtocol() as? ConcreteFakeableProtocol)
    XCTAssertTrue(concreteProtocolReference === fakeProtocolInstance)
    verify(concreteMock.fakeableProtocol()).wasCalled()
  }
  
  func testFakeableStruct() {
    let fakeStructInstance = FakeableStruct(value: 42)
    let valueProvider = ValueProvider().register(fakeStructInstance, for: FakeableStruct.self)
    useDefaultValues(from: valueProvider, on: concreteMock)
    
    XCTAssertEqual(concreteInstance.fakeableStruct(), fakeStructInstance)
    verify(concreteMock.fakeableStruct()).wasCalled()
  }
  
  func testFakeableEnum() {
    let valueProvider = ValueProvider().register(FakeableEnum.bar, for: FakeableEnum.self)
    useDefaultValues(from: valueProvider, on: concreteMock)
    XCTAssertEqual(concreteInstance.fakeableEnum(), .bar)
    verify(concreteMock.fakeableEnum()).wasCalled()
  }
  
  func testFakeableTypealias() {
    let valueProvider = ValueProvider().register(FakeableTypealias(), for: FakeableTypealias.self)
    useDefaultValues(from: valueProvider, on: concreteMock)
    XCTAssertEqual(concreteInstance.fakeableTypealias(), FakeableTypealias())
    verify(concreteMock.fakeableTypealias()).wasCalled()
  }
  
  func testFakeableTypealias_handlesAliasedType() {
    let valueProvider = ValueProvider().register(true, for: Bool.self)
    useDefaultValues(from: valueProvider, on: concreteMock)
    XCTAssertEqual(concreteInstance.fakeableTypealias(), true)
    verify(concreteMock.fakeableTypealias()).wasCalled()
  }
  
  func testFakeableInt() {
    let valueProvider = ValueProvider().register(42, for: Int.self)
    useDefaultValues(from: valueProvider, on: concreteMock)
    XCTAssertEqual(concreteInstance.fakeableInt(), 42)
    verify(concreteMock.fakeableInt()).wasCalled()
  }
  
  // MARK: - Resetting
  
  func testClearDefaultValues() {
    shouldFail {
      let valueProvider = ValueProvider().register(42, for: Int.self)
      useDefaultValues(from: valueProvider, on: self.concreteMock)
      clearDefaultValues(on: self.concreteMock)
      _ = self.concreteInstance.fakeableInt()
    }
  }
  
  // MARK: - Multiple registration

  func testChainedFakeableRegistration() {
    let fakeClassInstance = FakeableClass(param: "hello-world")
    let valueProvider = ValueProvider()
      .register(fakeClassInstance, for: FakeableClass.self)
      .register(FakeableEnum.bar, for: FakeableEnum.self)
      .register(42, for: Int.self)
    useDefaultValues(from: valueProvider, on: concreteMock)
    
    XCTAssertTrue(concreteInstance.fakeableClass() === fakeClassInstance)
    XCTAssertEqual(concreteInstance.fakeableEnum(), .bar)
    XCTAssertEqual(concreteInstance.fakeableInt(), 42)
    
    verify(concreteMock.fakeableClass()).wasCalled()
    verify(concreteMock.fakeableEnum()).wasCalled()
    verify(concreteMock.fakeableInt()).wasCalled()
  }
  
  func testMultipleFakeableRegistration_overridesPreviousRegistration() {
    let valueProvider = ValueProvider()
      .register(42, for: Int.self)
      .register(99, for: Int.self)
    useDefaultValues(from: valueProvider, on: concreteMock)
    XCTAssertEqual(concreteInstance.fakeableInt(), 99)
    verify(concreteMock.fakeableInt()).wasCalled()
  }
  
  func testRemovePreviousFakeableRegistration() {
    shouldFail {
      let valueProvider = ValueProvider()
        .register(42, for: Int.self)
        .removeValue(for: Int.self)
      useDefaultValues(from: valueProvider, on: self.concreteMock)
      _ = self.concreteInstance.fakeableInt()
    }
  }

  func testApplyValueProviderToMultipleMocks() {
    let valueProvider = ValueProvider()
      .register(42, for: Int.self)
      .register(99, for: Int.self)
    let anotherConcreteMock = mock(FakeableTypeReferencer.self)
    let anotherConcreteInstance = anotherConcreteMock as FakeableTypeReferencer
    useDefaultValues(from: valueProvider, on: [concreteMock, anotherConcreteMock])
    XCTAssertEqual(concreteInstance.fakeableInt(), 99)
    XCTAssertEqual(anotherConcreteInstance.fakeableInt(), 99)
    verify(concreteMock.fakeableInt()).wasCalled()
    verify(anotherConcreteMock.fakeableInt()).wasCalled()
  }
  
  // MARK: - Subprovider
  
  func testAddSingleSubprovider() {
    let valueProvider = ValueProvider().addSubprovider(.standardProvider)
    useDefaultValues(from: valueProvider, on: concreteMock)
    XCTAssertEqual(concreteInstance.fakeableString(), "")
    verify(concreteMock.fakeableString()).wasCalled()
  }
  
  func testAddMultipleSubproviders() {
    let valueProvider = ValueProvider()
      .addSubprovider(.collectionsProvider)
      .addSubprovider(.primitivesProvider)
    useDefaultValues(from: valueProvider, on: concreteMock)
    XCTAssertEqual(concreteInstance.fakeableArray(), [])
    XCTAssertEqual(concreteInstance.fakeableInt(), Int())
    verify(concreteMock.fakeableArray()).wasCalled()
    verify(concreteMock.fakeableInt()).wasCalled()
  }
  
  func testRemoveSubprovider() {
    shouldFail {
      let valueProvider = ValueProvider()
        .addSubprovider(.collectionsProvider)
        .removeSubprovider(.collectionsProvider)
      useDefaultValues(from: valueProvider, on: self.concreteMock)
      _ = self.concreteInstance.fakeableArray()
    }
  }
  
  func testRemoveAndReaddSubprovider() {
    let valueProvider = ValueProvider()
      .addSubprovider(.collectionsProvider)
      .removeSubprovider(.collectionsProvider)
      .addSubprovider(.collectionsProvider)
    useDefaultValues(from: valueProvider, on: concreteMock)
    XCTAssertEqual(concreteInstance.fakeableArray(), [])
    verify(concreteMock.fakeableArray()).wasCalled()
  }
  
  // MARK: - Precedence
  
  func testConcreteStubOverridesDefaultValueStub_priorToRegistration() {
    given(concreteMock.fakeableInt()) ~> 99
    let valueProvider = ValueProvider().register(42, for: Int.self)
    useDefaultValues(from: valueProvider, on: concreteMock)
    XCTAssertEqual(concreteInstance.fakeableInt(), 99)
    verify(concreteMock.fakeableInt()).wasCalled()
  }
  
  func testConcreteStubOverridesDefaultValueStub_afterRegistration() {
    let valueProvider = ValueProvider().register(42, for: Int.self)
    useDefaultValues(from: valueProvider, on: concreteMock)
    given(concreteMock.fakeableInt()) ~> 99
    XCTAssertEqual(concreteInstance.fakeableInt(), 99)
    verify(concreteMock.fakeableInt()).wasCalled()
  }
  
  // MARK: - Presets
  
  func testUseStandardProvider() {
    useDefaultValues(from: .standardProvider, on: concreteMock)
    XCTAssertEqual(concreteInstance.fakeableInt(), Int())
    XCTAssertEqual(concreteInstance.fakeableString(), String())
    XCTAssertEqual(concreteInstance.fakeableCGFloat(), CGFloat())
    XCTAssertLessThan(concreteInstance.fakeableDate(), Date())
    XCTAssertEqual(concreteInstance.fakeableArray(), [])
  }
  
  func testUsePrimitivesProvider() {
    useDefaultValues(from: .primitivesProvider, on: concreteMock)
    XCTAssertEqual(concreteInstance.fakeableInt(), Int())
    XCTAssertEqual(concreteInstance.fakeableUInt(), UInt())
    XCTAssertEqual(concreteInstance.fakeableFloat(), Float())
    XCTAssertEqual(concreteInstance.fakeableDouble(), Double())
    XCTAssertEqual(concreteInstance.fakeableBool(), Bool())
  }
  
  func testUseGeometryProvider() {
    useDefaultValues(from: .geometryProvider, on: concreteMock)
    XCTAssertEqual(concreteInstance.fakeableCGFloat(), CGFloat())
    XCTAssertEqual(concreteInstance.fakeableCGPoint(), CGPoint())
  }
  
  func testUseCollectionsProvider() {
    useDefaultValues(from: .collectionsProvider, on: concreteMock)
    XCTAssertEqual(concreteInstance.fakeableArray(), [])
    XCTAssertEqual(concreteInstance.fakeableSet(), [])
    XCTAssertEqual(concreteInstance.fakeableDictionary(), [:])
    XCTAssertEqual(concreteInstance.fakeableNSCache().name, "")
    XCTAssertEqual(concreteInstance.fakeableNSMapTable(), NSMapTable())
    XCTAssertEqual(concreteInstance.fakeableNSHashTable(), NSHashTable())
  }
  
  // MARK: - Tuples
  
  func testTuplesDefaultValueProvider_2Tuple() {
    useDefaultValues(from: .standardProvider, on: concreteMock)
    let tuple = concreteInstance.fakeable2Tuple()
    XCTAssertEqual(tuple.0, String())
    XCTAssertEqual(tuple.1, Int())
  }
  
  func testTuplesDefaultValueProvider_3Tuple() {
    useDefaultValues(from: .standardProvider, on: concreteMock)
    let tuple = concreteInstance.fakeable3Tuple()
    XCTAssertEqual(tuple.0, String())
    XCTAssertEqual(tuple.1, Int())
    XCTAssertEqual(tuple.2, Bool())
  }
  
  func testTuplesDefaultValueProvider_4Tuple() {
    useDefaultValues(from: .standardProvider, on: concreteMock)
    let tuple = concreteInstance.fakeable4Tuple()
    XCTAssertEqual(tuple.0, String())
    XCTAssertEqual(tuple.1, Int())
    XCTAssertEqual(tuple.2, Bool())
    XCTAssertEqual(tuple.3, Double())
  }
  
  func testTuplesDefaultValueProvider_5Tuple() {
    useDefaultValues(from: .standardProvider, on: concreteMock)
    let tuple = concreteInstance.fakeable5Tuple()
    XCTAssertEqual(tuple.0, String())
    XCTAssertEqual(tuple.1, Int())
    XCTAssertEqual(tuple.2, Bool())
    XCTAssertEqual(tuple.3, Double())
    XCTAssertEqual(tuple.4, Float())
  }
  
  func testTuplesDefaultValueProvider_6Tuple() {
    useDefaultValues(from: .standardProvider, on: concreteMock)
    let tuple = concreteInstance.fakeable6Tuple()
    XCTAssertEqual(tuple.0, String())
    XCTAssertEqual(tuple.1, Int())
    XCTAssertEqual(tuple.2, Bool())
    XCTAssertEqual(tuple.3, Double())
    XCTAssertEqual(tuple.4, Float())
    XCTAssertEqual(tuple.5, UInt())
  }
  
  // MARK: - Only explicit inclusion
  
  func testPrimitivesTypeGroup_excludesStringTypes() {
    shouldFail {
      useDefaultValues(from: .primitivesProvider, on: self.concreteMock)
      _ = self.concreteInstance.fakeableString()
    }
  }
  
  func testPrimitivesTypeGroup_excludesCollectionTypes() {
    shouldFail {
      useDefaultValues(from: .primitivesProvider, on: self.concreteMock)
      _ = self.concreteInstance.fakeableArray()
    }
  }
  
  func testStringsTypeGroup_excludesCollectionTypes() {
    shouldFail {
      useDefaultValues(from: .stringsProvider, on: self.concreteMock)
      _ = self.concreteInstance.fakeableArray()
    }
  }
  
  func testCollectionsTypeGroup_excludesPrimitiveTypes() {
    shouldFail {
      useDefaultValues(from: .collectionsProvider, on: self.concreteMock)
      _ = self.concreteInstance.fakeableBool()
    }
  }
  
  func testCommonTypeGroup_excludesCustomClassType() {
    shouldFail {
      useDefaultValues(from: .standardProvider, on: self.concreteMock)
      _ = self.concreteInstance.fakeableClass()
    }
  }
}

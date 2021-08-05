//
//  DefaultValueProviderTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 4/11/20.
//

import XCTest
import Mockingbird
@testable import MockingbirdTestsHost
import CoreBluetooth

extension FakeableGenericClass: Providable {
  public static func createInstance() -> Self? { FakeableGenericClass() as? Self }
}

class DefaultValueProviderTests: BaseTestCase {
  
  var concreteMock: FakeableTypeReferencerMock!
  var concreteInstance: FakeableTypeReferencer { return concreteMock }
  
  var childMock: ChildMock!
  var childInstance: Child { return childMock }
  
  var protocolMock: GrandparentProtocolMock!
  var protocolInstance: GrandparentProtocol { return protocolMock }
  
  override func setUp() {
    concreteMock = mock(FakeableTypeReferencer.self)
    childMock = mock(Child.self)
    protocolMock = mock(GrandparentProtocol.self)
  }
  
  // MARK: - Single registration
  
  func testFakeableClass() {
    let fakeClassInstance = FakeableClass(param: "hello-world")
    var valueProvider = ValueProvider()
    valueProvider.register(fakeClassInstance, for: FakeableClass.self)
    concreteMock.useDefaultValues(from: valueProvider)
    
    XCTAssertTrue(concreteInstance.fakeableClass() === fakeClassInstance)
    verify(concreteMock.fakeableClass()).wasCalled()
  }
  
  func testFakeableSpecializedGenericClass() {
    let fakeGenericClassInstance = FakeableGenericClass() as FakeableGenericClass<Bool>
    var valueProvider = ValueProvider()
    valueProvider.register(fakeGenericClassInstance, for: FakeableGenericClass<Bool>.self)
    concreteMock.useDefaultValues(from: valueProvider)
    
    let genericClassReference: FakeableGenericClass<Bool> = concreteInstance.fakeableGenericClass()
    XCTAssertTrue(genericClassReference === fakeGenericClassInstance)
    verify(concreteMock.fakeableGenericClass())
      .returning(FakeableGenericClass<Bool>.self)
      .wasCalled()
  }
  
  func testFakeableUnspecializedGenericClass() {
    var valueProvider = ValueProvider()
    valueProvider.registerType(FakeableGenericClass<Any>.self)
    concreteMock.useDefaultValues(from: valueProvider)
    
    let _ = concreteInstance.fakeableGenericClass() as FakeableGenericClass<Bool>
    let _ = concreteInstance.fakeableGenericClass() as FakeableGenericClass<String>
    let _ = concreteInstance.fakeableGenericClass() as FakeableGenericClass<Int>
    verify(concreteMock.fakeableGenericClass())
      .returning(FakeableGenericClass<Bool>.self)
      .wasCalled()
    verify(concreteMock.fakeableGenericClass())
      .returning(FakeableGenericClass<String>.self)
      .wasCalled()
    verify(concreteMock.fakeableGenericClass())
      .returning(FakeableGenericClass<Int>.self)
      .wasCalled()
  }
  
  func testFakeableProtocol() {
    class ConcreteFakeableProtocol: FakeableProtocol {}
    let fakeProtocolInstance = ConcreteFakeableProtocol()
    var valueProvider = ValueProvider()
    valueProvider.register(fakeProtocolInstance, for: FakeableProtocol.self)
    concreteMock.useDefaultValues(from: valueProvider)
    
    let concreteProtocolReference =
      (concreteInstance.fakeableProtocol() as? ConcreteFakeableProtocol)
    XCTAssertTrue(concreteProtocolReference === fakeProtocolInstance)
    verify(concreteMock.fakeableProtocol()).wasCalled()
  }
  
  func testFakeableStruct() {
    let fakeStructInstance = FakeableStruct(value: 42)
    var valueProvider = ValueProvider()
    valueProvider.register(fakeStructInstance, for: FakeableStruct.self)
    concreteMock.useDefaultValues(from: valueProvider)
    
    XCTAssertEqual(concreteInstance.fakeableStruct(), fakeStructInstance)
    verify(concreteMock.fakeableStruct()).wasCalled()
  }
  
  func testFakeableEnum() {
    var valueProvider = ValueProvider()
    valueProvider.register(FakeableEnum.bar, for: FakeableEnum.self)
    concreteMock.useDefaultValues(from: valueProvider)
    XCTAssertEqual(concreteInstance.fakeableEnum(), .bar)
    verify(concreteMock.fakeableEnum()).wasCalled()
  }
  
  func testFakeableTypealias() {
    var valueProvider = ValueProvider()
    valueProvider.register(FakeableTypealias(), for: FakeableTypealias.self)
    concreteMock.useDefaultValues(from: valueProvider)
    XCTAssertEqual(concreteInstance.fakeableTypealias(), FakeableTypealias())
    verify(concreteMock.fakeableTypealias()).wasCalled()
  }
  
  func testFakeableTypealias_handlesAliasedType() {
    var valueProvider = ValueProvider()
    valueProvider.register(true, for: Bool.self)
    concreteMock.useDefaultValues(from: valueProvider)
    XCTAssertEqual(concreteInstance.fakeableTypealias(), true)
    verify(concreteMock.fakeableTypealias()).wasCalled()
  }
  
  func testFakeableInt() {
    var valueProvider = ValueProvider()
    valueProvider.register(42, for: Int.self)
    concreteMock.useDefaultValues(from: valueProvider)
    XCTAssertEqual(concreteInstance.fakeableInt(), 42)
    verify(concreteMock.fakeableInt()).wasCalled()
  }
  
  // MARK: - Resetting
  
  func testClearDefaultValues() {
    shouldFail {
      var valueProvider = ValueProvider()
      valueProvider.register(42, for: Int.self)
      self.concreteMock.useDefaultValues(from: valueProvider)
      clearStubs(on: self.concreteMock)
      let _ = self.concreteInstance.fakeableInt()
    }
  }
  
  // MARK: - Multiple registration

  func testChainedFakeableRegistration() {
    let fakeClassInstance = FakeableClass(param: "hello-world")
    var valueProvider = ValueProvider()
    valueProvider.register(fakeClassInstance, for: FakeableClass.self)
    valueProvider.register(FakeableEnum.bar, for: FakeableEnum.self)
    valueProvider.register(42, for: Int.self)
    concreteMock.useDefaultValues(from: valueProvider)
    
    XCTAssertTrue(concreteInstance.fakeableClass() === fakeClassInstance)
    XCTAssertEqual(concreteInstance.fakeableEnum(), .bar)
    XCTAssertEqual(concreteInstance.fakeableInt(), 42)
    
    verify(concreteMock.fakeableClass()).wasCalled()
    verify(concreteMock.fakeableEnum()).wasCalled()
    verify(concreteMock.fakeableInt()).wasCalled()
  }
  
  func testMultipleFakeableRegistration_overridesPreviousRegistration() {
    var valueProvider = ValueProvider()
    valueProvider.register(42, for: Int.self)
    valueProvider.register(99, for: Int.self)
    concreteMock.useDefaultValues(from: valueProvider)
    XCTAssertEqual(concreteInstance.fakeableInt(), 99)
    verify(concreteMock.fakeableInt()).wasCalled()
  }
  
  func testRemovePreviousFakeableRegistration() {
    shouldFail {
      var valueProvider = ValueProvider()
      valueProvider.register(42, for: Int.self)
      valueProvider.remove(Int.self)
      self.concreteMock.useDefaultValues(from: valueProvider)
      _ = self.concreteInstance.fakeableInt()
    }
  }
  
  func testRemovePreviousGenericFakeableRegistration() {
    shouldFail {
      var valueProvider = ValueProvider()
      valueProvider.registerType(FakeableGenericClass<Any>.self)
      valueProvider.remove(FakeableGenericClass<Any>.self)
      self.concreteMock.useDefaultValues(from: valueProvider)
      _ = self.concreteInstance.fakeableGenericClass() as FakeableGenericClass<Bool>
    }
  }
  
  // MARK: - Composition
  
  func testAddSingleSubprovider() {
    var valueProvider = ValueProvider()
    valueProvider.add(.standardProvider)
    concreteMock.useDefaultValues(from: valueProvider)
    XCTAssertEqual(concreteInstance.fakeableString(), "")
    verify(concreteMock.fakeableString()).wasCalled()
  }
  
  func testAddSingleSubprovider_operatorSyntax() {
    let valueProvider = ValueProvider() + .standardProvider
    concreteMock.useDefaultValues(from: valueProvider)
    XCTAssertEqual(concreteInstance.fakeableString(), "")
    verify(concreteMock.fakeableString()).wasCalled()
  }
  
  func testAddMultipleSubproviders() {
    var valueProvider = ValueProvider()
    valueProvider.add(.collectionsProvider)
    valueProvider.add(.primitivesProvider)
    concreteMock.useDefaultValues(from: valueProvider)
    XCTAssertEqual(concreteInstance.fakeableArray(), [])
    XCTAssertEqual(concreteInstance.fakeableInt(), Int())
    verify(concreteMock.fakeableArray()).wasCalled()
    verify(concreteMock.fakeableInt()).wasCalled()
  }
  
  func testAddMultipleSubproviders_nonMutatingOperation() {
    let valueProvider = ValueProvider.collectionsProvider.adding(.primitivesProvider)
    concreteMock.useDefaultValues(from: valueProvider)
    XCTAssertEqual(concreteInstance.fakeableArray(), [])
    XCTAssertEqual(concreteInstance.fakeableInt(), Int())
    verify(concreteMock.fakeableArray()).wasCalled()
    verify(concreteMock.fakeableInt()).wasCalled()
  }
  
  func testAddMultipleSubproviders_nonMutatingOperation_operatorSyntax() {
    let valueProvider = .collectionsProvider + .primitivesProvider
    concreteMock.useDefaultValues(from: valueProvider)
    XCTAssertEqual(concreteInstance.fakeableArray(), [])
    XCTAssertEqual(concreteInstance.fakeableInt(), Int())
    verify(concreteMock.fakeableArray()).wasCalled()
    verify(concreteMock.fakeableInt()).wasCalled()
  }
  
  // MARK: - Precedence
  
  func testConcreteStubOverridesDefaultValueStub_priorToRegistration() {
    given(concreteMock.fakeableInt()) ~> 99
    var valueProvider = ValueProvider()
    valueProvider.register(42, for: Int.self)
    concreteMock.useDefaultValues(from: valueProvider)
    XCTAssertEqual(concreteInstance.fakeableInt(), 99)
    verify(concreteMock.fakeableInt()).wasCalled()
  }
  
  func testConcreteStubOverridesDefaultValueStub_afterRegistration() {
    var valueProvider = ValueProvider()
    valueProvider.register(42, for: Int.self)
    concreteMock.useDefaultValues(from: valueProvider)
    given(concreteMock.fakeableInt()) ~> 99
    XCTAssertEqual(concreteInstance.fakeableInt(), 99)
    verify(concreteMock.fakeableInt()).wasCalled()
  }
  
  // MARK: - Presets
  
  func testUseStandardProvider() {
    concreteMock.useDefaultValues(from: .standardProvider)
    XCTAssertEqual(concreteInstance.fakeableInt(), Int())
    XCTAssertEqual(concreteInstance.fakeableString(), String())
    XCTAssertEqual(concreteInstance.fakeableCGFloat(), CGFloat())
    XCTAssertLessThan(concreteInstance.fakeableDate(), Date())
    XCTAssertEqual(concreteInstance.fakeableArray(), [])
  }
  
  func testUseStandardProviderWithObjCTypeFromProperty() {
    let objcMock = mock(CBPeripheral.self).useDefaultValues(from: .standardProvider)
    XCTAssertEqual(objcMock.canSendWriteWithoutResponse, Bool())
    verify(objcMock.canSendWriteWithoutResponse).wasCalled()
  }
  
  func testUseStandardProviderWithObjCTypeFromMethod() {
    let objcMock = mock(CBPeripheral.self).useDefaultValues(from: .standardProvider)
    XCTAssertEqual(objcMock.maximumWriteValueLength(for: .withResponse), Int())
    verify(objcMock.maximumWriteValueLength(for: .withResponse)).wasCalled()
  }
  
  func testUsePrimitivesProvider() {
    concreteMock.useDefaultValues(from: .primitivesProvider)
    XCTAssertEqual(concreteInstance.fakeableInt(), Int())
    XCTAssertEqual(concreteInstance.fakeableUInt(), UInt())
    XCTAssertEqual(concreteInstance.fakeableFloat(), Float())
    XCTAssertEqual(concreteInstance.fakeableDouble(), Double())
    XCTAssertEqual(concreteInstance.fakeableBool(), Bool())
  }
  
  func testUseCollectionsProvider() {
    concreteMock.useDefaultValues(from: .collectionsProvider)
    XCTAssertEqual(concreteInstance.fakeableArray(), [])
    XCTAssertEqual(concreteInstance.fakeableSet(), [])
    XCTAssertEqual(concreteInstance.fakeableDictionary(), [:])
  }
  
  // MARK: - Tuples
  
  func testTuplesDefaultValueProvider_2Tuple() {
    concreteMock.useDefaultValues(from: .standardProvider)
    let tuple = concreteInstance.fakeable2Tuple()
    XCTAssertEqual(tuple.0, String())
    XCTAssertEqual(tuple.1, Int())
  }
  
  func testTuplesDefaultValueProvider_3Tuple() {
    concreteMock.useDefaultValues(from: .standardProvider)
    let tuple = concreteInstance.fakeable3Tuple()
    XCTAssertEqual(tuple.0, String())
    XCTAssertEqual(tuple.1, Int())
    XCTAssertEqual(tuple.2, Bool())
  }
  
  func testTuplesDefaultValueProvider_4Tuple() {
    concreteMock.useDefaultValues(from: .standardProvider)
    let tuple = concreteInstance.fakeable4Tuple()
    XCTAssertEqual(tuple.0, String())
    XCTAssertEqual(tuple.1, Int())
    XCTAssertEqual(tuple.2, Bool())
    XCTAssertEqual(tuple.3, Double())
  }
  
  func testTuplesDefaultValueProvider_5Tuple() {
    concreteMock.useDefaultValues(from: .standardProvider)
    let tuple = concreteInstance.fakeable5Tuple()
    XCTAssertEqual(tuple.0, String())
    XCTAssertEqual(tuple.1, Int())
    XCTAssertEqual(tuple.2, Bool())
    XCTAssertEqual(tuple.3, Double())
    XCTAssertEqual(tuple.4, Float())
  }
  
  func testTuplesDefaultValueProvider_6Tuple() {
    concreteMock.useDefaultValues(from: .standardProvider)
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
      self.concreteMock.useDefaultValues(from: .primitivesProvider)
      _ = self.concreteInstance.fakeableString()
    }
  }
  
  func testPrimitivesTypeGroup_excludesCollectionTypes() {
    shouldFail {
      self.concreteMock.useDefaultValues(from: .primitivesProvider)
      _ = self.concreteInstance.fakeableArray()
    }
  }
  
  func testStringsTypeGroup_excludesCollectionTypes() {
    shouldFail {
      self.concreteMock.useDefaultValues(from: .stringsProvider)
      _ = self.concreteInstance.fakeableArray()
    }
  }
  
  func testCollectionsTypeGroup_excludesPrimitiveTypes() {
    shouldFail {
      self.concreteMock.useDefaultValues(from: .collectionsProvider)
      _ = self.concreteInstance.fakeableBool()
    }
  }
  
  func testCommonTypeGroup_excludesCustomClassType() {
    shouldFail {
      self.concreteMock.useDefaultValues(from: .standardProvider)
      _ = self.concreteInstance.fakeableClass()
    }
  }
}

private class ProtocolImplementation: GrandparentProtocol {
  var grandparentPrivateSetterInstanceVariable = true
  var grandparentInstanceVariable = true
  func grandparentTrivialInstanceMethod() {}
  func grandparentParameterizedInstanceMethod(param1: Bool, _ param2: Int) -> Bool { return true }
  static var grandparentPrivateSetterStaticVariable = true
  static var grandparentStaticVariable = true
  static func grandparentTrivialStaticMethod() {}
  static func grandparentParameterizedStaticMethod(param1: Bool, _ param2: Int) -> Bool {
    return true
  }
}

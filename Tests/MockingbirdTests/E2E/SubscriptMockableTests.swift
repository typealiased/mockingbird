//
//  SubscriptMockableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 4/25/20.
//

import Foundation
import Mockingbird
@testable import MockingbirdTestsHost

// MARK: - Mockable declarations

private protocol MockableSubscriptedProtocol: SubscriptedProtocol, Mock {}
extension SubscriptedProtocolMock: MockableSubscriptedProtocol {}
extension SubscriptedClassMock: MockableSubscriptedProtocol {}

private protocol MockableDynamicMemberLookupClass: Mock {
  subscript(dynamicMember member: String) -> Int { get set }
}
extension DynamicMemberLookupClassMock: MockableDynamicMemberLookupClass {}

private protocol MockableGenericDynamicMemberLookupClass: Mock {
  subscript<T>(dynamicMember member: String) -> T { get set }
}
extension GenericDynamicMemberLookupClassMock: MockableGenericDynamicMemberLookupClass {}

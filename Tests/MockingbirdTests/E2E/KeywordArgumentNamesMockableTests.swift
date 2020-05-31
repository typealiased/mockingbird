//
//  KeywordArgumentNamesMockableTests.swift
//  MockingbirdTests
//
//  Created by Ryan Meisters on 2/9/20.
//

import Foundation
import Mockingbird
@testable import MockingbirdTestsHost

// MARK: - Mockable declarations

private protocol MockableKeywordArgNamesProtocol: KeywordArgNamesProtocol, Mock {}

extension KeywordArgNamesProtocolMock: MockableKeywordArgNamesProtocol {}

extension KeywordArgNamesClassMock: MockableKeywordArgNamesProtocol {}

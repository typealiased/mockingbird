//
//  UndefinedArgumentLabelsMockableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/28/19.
//

import Foundation
@testable import MockingbirdTestsHost

// MARK: - Mockable declarations

private protocol MockableUndefinedArgumentLabels: UndefinedArgumentLabels {}
extension UndefinedArgumentLabelsMock: MockableUndefinedArgumentLabels {}

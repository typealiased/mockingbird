//
//  IgnoredSourceInclusionTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 4/3/20.
//

import Foundation
@testable import MockingbirdTestsHost

// MARK: - Included top-level types

extension TrivialIncludedSourceMock {}

extension CascadingIncludedSourceMock {}

extension OverriddenIncludedSourceMock {}

extension EnclosingDirectoryOverriddenIncludedSourceMock {}

extension RelativeSecondLevelFileIncludedSourceMock {}

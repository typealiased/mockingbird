//
//  IgnoredSourceExclusionTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 9/11/19.
//

import Foundation
@testable import MockingbirdTestsHost

// MARK: - Excluded top-level types

class TopLevelFileIgnoredSourceMock {}

class RelativeTopLevelFileIgnoredSourceMock {}

class SecondLevelFileIgnoredSourceMock {}

class CascadingExcludedSourceMock {}

class EscapedNegationPrefixIgnoredSourceMock {}

class EscapedCommentPrefixIgnoredSourceMock {}

class NonRelativeSecondLevelFileIgnoredSourceMock {}

class DirectoryIgnoredSourceMock {}

class WildcardFileIgnoredSourceMock {}

class WildcardDirectoryIgnoredSourceMock {}

class EnclosingDirectoryOverriddenIgnoredSourceMock {}

class NonRelativeDirectoryIgnoredSourceMock {}

class NonRelativeWildcardFileIgnoredSourceMock {}

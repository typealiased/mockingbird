//
//  IgnoredSourceExclusionTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 9/11/19.
//

import Foundation
import Mockingbird
@testable import MockingbirdTestsHost

// MARK: - Excluded declarations

extension TopLevelFileIgnoredSource {
  func canary() -> Mockable<MethodDeclaration, () -> Void, Void> { return any() }
}

extension SecondLevelFileIgnoredSource {
  func canary() -> Mockable<MethodDeclaration, () -> Void, Void> { return any() }
}

extension DirectoryIgnoredSource1 {
  func canary() -> Mockable<MethodDeclaration, () -> Void, Void> { return any() }
}

extension DirectoryIgnoredSource2 {
  func canary() -> Mockable<MethodDeclaration, () -> Void, Void> { return any() }
}

extension WildcardFileIgnoredSource {
  func canary() -> Mockable<MethodDeclaration, () -> Void, Void> { return any() }
}

extension WildcardDirectoryIgnoredSource1 {
  func canary() -> Mockable<MethodDeclaration, () -> Void, Void> { return any() }
}

extension WildcardDirectoryIgnoredSource2 {
  func canary() -> Mockable<MethodDeclaration, () -> Void, Void> { return any() }
}

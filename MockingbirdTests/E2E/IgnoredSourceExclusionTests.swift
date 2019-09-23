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
  func canary() -> Mockable<MethodDeclaration, () -> Void, Void> { fatalError() }
}

extension SecondLevelFileIgnoredSource {
  func canary() -> Mockable<MethodDeclaration, () -> Void, Void> { fatalError() }
}

extension DirectoryIgnoredSource1 {
  func canary() -> Mockable<MethodDeclaration, () -> Void, Void> { fatalError() }
}

extension DirectoryIgnoredSource2 {
  func canary() -> Mockable<MethodDeclaration, () -> Void, Void> { fatalError() }
}

extension WildcardFileIgnoredSource {
  func canary() -> Mockable<MethodDeclaration, () -> Void, Void> { fatalError() }
}

extension WildcardDirectoryIgnoredSource1 {
  func canary() -> Mockable<MethodDeclaration, () -> Void, Void> { fatalError() }
}

extension WildcardDirectoryIgnoredSource2 {
  func canary() -> Mockable<MethodDeclaration, () -> Void, Void> { fatalError() }
}

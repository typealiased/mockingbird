//
//  ExternalModuleImplicitlyImportedTypes.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 2/29/20.
//

import Foundation
import MockingbirdModuleTestsHost

// Implicitly importing `ExternalObjectiveCProtocol` from `MockingbirdModuleTestsHost` via header.
protocol ImplicitlyImportedExternalObjectiveCType: ExternalObjectiveCProtocol {}

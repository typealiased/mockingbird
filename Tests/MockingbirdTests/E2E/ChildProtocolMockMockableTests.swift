//
//  ChildProtocolMockMockableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/18/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import Mockingbird
@testable import MockingbirdTestsHost

private protocol MockableChildProtocol: ParentProtocol, Mock {}
extension ChildProtocolMock: MockableChildProtocol {}

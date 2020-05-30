//
//  InoutParameters.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 8/21/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation

protocol InoutProtocol {
  func parameterizedMethod(object: inout String)
}

class InoutClass {
  func parameterizedMethod(object: inout String) {}
}

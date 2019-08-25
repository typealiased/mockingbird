//
//  ClassInitializers.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 8/25/19.
//

import Foundation

class NoInitializerClass {}

class EmptyInitializerClass {
  init() {}
}

class ParameterizedInitializerClass {
  init(param1: Bool, param2: Int) {}
}

class RequiredInitializerClass {
  required init(param1: Bool, param2: Int) {}
}

class ConvenienceInitializerClass {
  init(param1: Bool, param2: Int) {}
  convenience init(param1: Bool) {
    self.init(param1: param1, param2: 1)
  }
}

//
//  ClassInitializers.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 8/25/19.
//

import Foundation

class NoInitializerClass {}

class InheritingNoInitializerClass: NoInitializerClass {}
class IndirectlyInheritingNoInitializerClass: InheritingNoInitializerClass {}

protocol ConformingToNoInitializerClass: NoInitializerClass {}
protocol IndirectlyConformingToNoInitializerClass: ConformingToNoInitializerClass {}

class EmptyInitializerClass {
  init() {}
}

class InheritingEmptyInitializerClass: EmptyInitializerClass {}
class IndirectlyInheritingEmptyInitializerClass: InheritingEmptyInitializerClass {}

protocol ConformingToEmptyInitializerClass: EmptyInitializerClass {}
protocol IndirectlyConformingToEmptyInitializerClass: ConformingToEmptyInitializerClass {}

class PrivateInitializerClass {
  private init() {}
}

class InheritingPrivateInitializerClass: PrivateInitializerClass {}
class IndirectlyInheritingPrivateInitializerClass: InheritingPrivateInitializerClass {}

protocol ConformingToPrivateInitializerClass: PrivateInitializerClass {}
protocol IndirectlyConformingToPrivateInitializerClass: ConformingToPrivateInitializerClass {}

class PrivateInitializerClassWithAccessibleInitializer {
  private init() {}
  init(param: Bool) {}
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

class FailableEmptyInitializerClass {
  init?() {}
}

class FailableUnwrappedEmptyInitializerClass {
  init!() {}
}

class FailableParameterizedInitializerClass {
  init?(param1: Bool, param2: Int) {}
}

class FailableUnwrappedParameterizedInitializerClass {
  init!(param1: Bool, param2: Int) {}
}

//
//  ClosureAttributes.swift
//  MockingbirdTestsHost
//
//  Created by Peter Tolsma on 9/25/21.
//

import Foundation

class ClosureAttributesGenericBase<M> {
  func doGenericEscaping(output: @escaping () -> M?) -> M? {
    output()
  }

  func doConcreteEscaping(output: @escaping () -> Int) -> Int {
    output()
  }

  func doGenericInout(output: inout () -> M) -> M {
    output()
  }

  func doConcreteInout(output: inout () -> Int) -> Int {
    output()
  }

  func doGenericAutoclosure(output: @autoclosure () -> M) -> M {
    output()
  }

  func doConcreteAutoclosure(output: @autoclosure () -> Int) -> Int {
    output()
  }

  func doGenericEscapingAutoclosure(output: @escaping @autoclosure () -> M) -> M {
    output()
  }

  func doConcreteEscapingAutoclosure(output: @escaping @autoclosure () -> Int) -> Int {
    output()
  }
}

class ClosureAttributesConcreteChild: ClosureAttributesGenericBase<String> {
  func doAnotherThing() -> String {
    return doGenericEscaping { "42" } ?? "21"
  }
}

protocol ClosureAttributesProtocol {
  func doEscaping(output: @escaping () -> Double) -> Double
  func doInout(output: inout () -> [Character]) -> [Character]
  func doAutoclosure(output: @autoclosure () -> String) -> String
  func doEscapingAutoclosure(output: @escaping @autoclosure () -> Range<Int>) -> Range<Int>
}

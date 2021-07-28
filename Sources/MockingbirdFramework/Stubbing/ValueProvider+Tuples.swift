//
//  ValueProvider+Tuples.swift
//  MockingbirdFramework
//
//  Created by Andrew Chang on 4/13/20.
//

import Foundation

// Tuples only work for non-generic types, since generic parameters cannot be inferred here.
extension ValueProvider {
  func provideValue<T1, T2>(for type: (T1, T2).Type) -> (T1, T2)? {
    if let tupleValue = storedValues[ObjectIdentifier(type)] as? (T1, T2) {
      return tupleValue
    } else if
      let t1 = provideValue(for: T1.self),
      let t2 = provideValue(for: T2.self) {
      return (t1, t2)
    } else {
      return nil
    }
  }
  
  func provideValue<T1, T2, T3>(for type: (T1, T2, T3).Type) -> (T1, T2, T3)? {
    if let tupleValue = storedValues[ObjectIdentifier(type)] as? (T1, T2, T3) {
      return tupleValue
    } else if
      let t1 = provideValue(for: T1.self),
      let t2 = provideValue(for: T2.self),
      let t3 = provideValue(for: T3.self) {
      return (t1, t2, t3)
    } else {
      return nil
    }
  }
  
  func provideValue<T1, T2, T3, T4>(for type: (T1, T2, T3, T4).Type) -> (T1, T2, T3, T4)? {
    if let tupleValue = storedValues[ObjectIdentifier(type)] as? (T1, T2, T3, T4) {
      return tupleValue
    } else if
      let t1 = provideValue(for: T1.self),
      let t2 = provideValue(for: T2.self),
      let t3 = provideValue(for: T3.self),
      let t4 = provideValue(for: T4.self) {
      return (t1, t2, t3, t4)
    } else {
      return nil
    }
  }
  
  func provideValue<T1, T2, T3, T4, T5>(for type: (T1, T2, T3, T4, T5).Type)
    -> (T1, T2, T3, T4, T5)? {
      if let tupleValue = storedValues[ObjectIdentifier(type)] as? (T1, T2, T3, T4, T5) {
        return tupleValue
      } else if
        let t1 = provideValue(for: T1.self),
        let t2 = provideValue(for: T2.self),
        let t3 = provideValue(for: T3.self),
        let t4 = provideValue(for: T4.self),
        let t5 = provideValue(for: T5.self) {
        return (t1, t2, t3, t4, t5)
      } else {
        return nil
      }
  }
  
  func provideValue<T1, T2, T3, T4, T5, T6>(for type: (T1, T2, T3, T4, T5, T6).Type)
    -> (T1, T2, T3, T4, T5, T6)? {
      if let tupleValue = storedValues[ObjectIdentifier(type)] as? (T1, T2, T3, T4, T5, T6) {
        return tupleValue
      } else if
        let t1 = provideValue(for: T1.self),
        let t2 = provideValue(for: T2.self),
        let t3 = provideValue(for: T3.self),
        let t4 = provideValue(for: T4.self),
        let t5 = provideValue(for: T5.self),
        let t6 = provideValue(for: T6.self) {
        return (t1, t2, t3, t4, t5, t6)
      } else {
        return nil
      }
  }
  
  // MARK: - Optionals
  
  func provideValue<T1, T2>(for type: (T1?, T2?).Type) -> (T1?, T2?)? {
    if let tupleValue = storedValues[ObjectIdentifier(type)] as? (T1?, T2?) {
      return tupleValue
    } else if
      let t1 = provideValue(for: T1.self),
      let t2 = provideValue(for: T2.self) {
      return (t1, t2)
    } else {
      return nil
    }
  }
  
  func provideValue<T1, T2, T3>(for type: (T1?, T2?, T3?).Type) -> (T1?, T2?, T3?)? {
    if let tupleValue = storedValues[ObjectIdentifier(type)] as? (T1?, T2?, T3?) {
      return tupleValue
    } else if
      let t1 = provideValue(for: T1.self),
      let t2 = provideValue(for: T2.self),
      let t3 = provideValue(for: T3.self) {
      return (t1, t2, t3)
    } else {
      return nil
    }
  }
  
  func provideValue<T1, T2, T3, T4>(for type: (T1?, T2?, T3?, T4?).Type) -> (T1?, T2?, T3?, T4?)? {
    if let tupleValue = storedValues[ObjectIdentifier(type)] as? (T1?, T2?, T3?, T4?) {
      return tupleValue
    } else if
      let t1 = provideValue(for: T1.self),
      let t2 = provideValue(for: T2.self),
      let t3 = provideValue(for: T3.self),
      let t4 = provideValue(for: T4.self) {
      return (t1, t2, t3, t4)
    } else {
      return nil
    }
  }
  
  func provideValue<T1, T2, T3, T4, T5>(for type: (T1?, T2?, T3?, T4?, T5?).Type)
    -> (T1?, T2?, T3?, T4?, T5?)? {
      if let tupleValue = storedValues[ObjectIdentifier(type)] as? (T1?, T2?, T3?, T4?, T5?) {
        return tupleValue
      } else if
        let t1 = provideValue(for: T1.self),
        let t2 = provideValue(for: T2.self),
        let t3 = provideValue(for: T3.self),
        let t4 = provideValue(for: T4.self),
        let t5 = provideValue(for: T5.self) {
        return (t1, t2, t3, t4, t5)
      } else {
        return nil
      }
  }
  
  func provideValue<T1, T2, T3, T4, T5, T6>(for type: (T1?, T2?, T3?, T4?, T5?, T6?).Type)
    -> (T1?, T2?, T3?, T4?, T5?, T6?)? {
      if let tupleValue =
        storedValues[ObjectIdentifier(type)] as? (T1?, T2?, T3?, T4?, T5?, T6?) {
        return tupleValue
      } else if
        let t1 = provideValue(for: T1.self),
        let t2 = provideValue(for: T2.self),
        let t3 = provideValue(for: T3.self),
        let t4 = provideValue(for: T4.self),
        let t5 = provideValue(for: T5.self),
        let t6 = provideValue(for: T6.self) {
        return (t1, t2, t3, t4, t5, t6)
      } else {
        return nil
      }
  }
}

//
//  Deallocation.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 4/23/20.
//

import Foundation

private let objectReferences = Synchronized<[Any]>([])
private let queue = DispatchQueue(label: "co.bird.mockingbird.retain", qos: .background)

/// Retain an object for the lifetime of the application.
///
/// The generator is mostly CPU-bound and doesn't really have memory constraints. By forcing certain
/// object lifetimes to extend until the program exits we can let the OS take care of deallocations.
///
/// - Parameter object: A class object to retain.
func retainForever<T: AnyObject>(_ object: T?) {
  guard let object = object else { return }
  #if !(DEBUG)
  queue.async { objectReferences.value.append(object) }
  #endif
}

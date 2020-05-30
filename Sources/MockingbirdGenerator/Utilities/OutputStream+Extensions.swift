//
//  OutputStream+Extensions.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 4/24/20.
//

import Foundation

public extension OutputStream {
  /// Write UTF-8 encoded data to this output stream.
  ///
  /// - Parameter data: UTF-8 encoded data to write.
  /// - Returns: The number of bytes written.
  @discardableResult
  func write(data: Data) -> Int {
    return data.withUnsafeBytes({
      write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: data.count)
    })
  }
}

//
//  String+SHA1.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 9/29/19.
//

import Foundation
import CommonCrypto

public enum HashFailure: Error {
  case malformedData(description: String)
  case unexpectedError(description: String)
  
  var localizedDescription: String {
    switch self {
    case .malformedData(let description): return "Malformed data - \(description)"
    case .unexpectedError(let description): return "Unexpected error - \(description)"
    }
  }
}

extension String {
  @inlinable
  public func generateSha1Hash() throws -> String {
    guard let data = data(using: .utf8, allowLossyConversion: false) else {
      throw HashFailure.malformedData(
        description: "Unable to convert `\(self)` into UTF-8 data encoding"
      )
    }
    return try data.generateSha1Hash()
  }
}

extension Data {
  @inlinable
  public func generateSha1Hash() throws -> String {
    let hash = try withUnsafeBytes({ (pointer: UnsafeRawBufferPointer) throws -> [UInt8] in
      guard let bytes = pointer.baseAddress else {
        throw HashFailure.unexpectedError(description: "Unable to initialize data buffer pointer")
      }
      var hash = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
      CC_SHA1(bytes, CC_LONG(count), &hash)
      return hash
    })
    return hash.map({ String(format: "%02x", $0) }).joined()
  }
}

//
//  String+SHA1.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 9/29/19.
//

import Foundation
import CommonCrypto

extension String {
  @inlinable
  public func generateSha1Hash() -> String? {
    guard let data = data(using: .utf8, allowLossyConversion: false) else { return nil }
    return data.generateSha1Hash()
  }
}

extension Data {
  @inlinable
  public func generateSha1Hash() -> String? {
    let hash = withUnsafeBytes({ (pointer: UnsafeRawBufferPointer) -> [UInt8]? in
      guard let bytes = pointer.baseAddress else { return nil }
      var hash = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
      CC_SHA1(bytes, CC_LONG(count), &hash)
      return hash
    })
    return hash?.map({ String(format: "%02x", $0) }).joined()
  }
}

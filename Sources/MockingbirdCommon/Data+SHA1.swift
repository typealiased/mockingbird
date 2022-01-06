import Foundation
import CommonCrypto

public extension Data {
  /// Returns a SHA-1 digest as a hex-formatted string.
  func hash() -> String {
    let hash = withUnsafeBytes({ (pointer: UnsafeRawBufferPointer) -> [UInt8] in
      var hash = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
      CC_SHA1(pointer.baseAddress!, CC_LONG(count), &hash)
      return hash
    })
    return hash.map({ String(format: "%02x", $0) }).joined()
  }
}

public extension String {
  struct EncodingError: LocalizedError {
    let encoding: Encoding
    public var errorDescription: String? {
      "The string cannot be encoded to \(singleQuoted: String(describing: encoding))"
    }
  }
  
  /// Returns a SHA-1 digest as a hex-formatted string.
  func hash(as encoding: Encoding = .utf8) throws -> String {
    guard let encodedData = data(using: encoding, allowLossyConversion: false) else {
      throw EncodingError(encoding: encoding)
    }
    return encodedData.hash()
  }
}

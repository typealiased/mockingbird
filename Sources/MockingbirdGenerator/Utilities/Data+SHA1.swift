import Foundation
import Crypto

public extension Data {
  /// Returns a SHA-1 digest as a hex-formatted string.
  func hash() -> String {
    return Insecure.SHA1.hash(data: self).prefix(Insecure.SHA1.byteCount).map({
      String(format: "%02x", $0)
    }).joined()
  }
}

public extension String {
  struct EncodingError: LocalizedError {
    let encoding: Encoding
    public var errorDescription: String? {
      "The string cannot be encoded to \(singleQuoted: String(describing: encoding))"
    }
  }
  
  /// Returns a SHA-1 digest of the current string.
  func hash(as encoding: Encoding = .utf8) throws -> String {
    guard let encodedData = data(using: encoding, allowLossyConversion: false) else {
      throw EncodingError(encoding: encoding)
    }
    return encodedData.hash()
  }
}

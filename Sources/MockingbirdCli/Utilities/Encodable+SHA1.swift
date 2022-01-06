import Foundation
import MockingbirdCommon

extension Encodable {
  /// Encodes the instance to a stable SHA-1 hash.
  func toSha1Hash() throws -> String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .sortedKeys
    return try encoder.encode(self).hash()
  }
}

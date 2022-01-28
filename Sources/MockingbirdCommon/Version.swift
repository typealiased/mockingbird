import Foundation

/// The current version of Mockingbird.
public let mockingbirdVersion = Version(shortString: "0.20.0")

/// A comparable semantic version.
public struct Version: Comparable, CustomStringConvertible {
  public let semver: [Int]
  public var shortString: String { return semver.map({ "\($0)" }).joined(separator: ".") }
  public var description: String { return shortString }
  
  public init(semver: [Int]) {
    self.semver = semver
  }
  
  public init(shortString: String) {
    self.init(semver: shortString.components(separatedBy: ".").map({ Int($0) ?? 0 }))
  }
  
  public static func < (lhs: Version, rhs: Version) -> Bool {
    for i in 0..<min(lhs.semver.count, rhs.semver.count) {
      if lhs.semver[i] < rhs.semver[i] { return true }
    }
    return lhs.semver.count < rhs.semver.count
  }
  
  public static func << (lhs: Version, rhs: Version) -> Bool {
    return lhs.semver.first ?? 0 < rhs.semver.first ?? 0
  }
}

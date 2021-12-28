import Foundation

public extension FileManager {
  enum PosixPermissions {
    public static let writeOnly: Int = 0o355
    public static let readWrite: Int = 0o755
  }
}

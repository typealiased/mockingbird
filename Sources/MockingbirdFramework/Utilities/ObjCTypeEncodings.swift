import Foundation

/// Maps Objective-C runtime type encodings to a Swift `ObjectIdentifier`.
///
/// Based on the Objective-C runtime encoding table:
/// https://developer.apple.com/library/archive/documentation
///   /Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
let objCTypeEncodings: [String: ObjectIdentifier] = [
  "c": ObjectIdentifier(CChar.self),
  "C": ObjectIdentifier(CUnsignedChar.self),
  "s": ObjectIdentifier(CShort.self),
  "i": ObjectIdentifier(CInt.self),
  "l": ObjectIdentifier(CLong.self),
  "I": ObjectIdentifier(CUnsignedInt.self),
  "q": ObjectIdentifier(CLongLong.self),
  "L": ObjectIdentifier(CUnsignedLong.self),
  "S": ObjectIdentifier(CUnsignedShort.self),
  "Q": ObjectIdentifier(CUnsignedLongLong.self),
  "f": ObjectIdentifier(CFloat.self),
  "d": ObjectIdentifier(CDouble.self),
  "B": ObjectIdentifier(CBool.self),
  "v": ObjectIdentifier(Void.self),
  "*": ObjectIdentifier(UnsafePointer<CChar>.self),
]

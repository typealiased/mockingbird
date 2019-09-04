//
//  Path+Extensions.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 9/3/19.
//

import Foundation
import PathKit

enum WriteUtf8StringFailure: Error, CustomStringConvertible {
  case streamCreationFailure(path: Path)
  case dataEncodingFailure
  case streamWritingFailure(error: Error?)
  
  var description: String {
    switch self {
    case .streamCreationFailure(let path): return "Unable to create output stream to \(path)"
    case .dataEncodingFailure: return "Unable to encode data to UTF8"
    case .streamWritingFailure(let error): return "Failed to write to output stream, error: \(error?.localizedDescription ?? "(nil)")"
    }
  }
}

private class FileManagerMoveDelegate: NSObject, FileManagerDelegate {
  func fileManager(_ fileManager: FileManager, shouldMoveItemAt srcURL: URL, to dstURL: URL)
    -> Bool { return true }
  
  func fileManager(_ fileManager: FileManager,
                   shouldProceedAfterError error: Error,
                   movingItemAt srcURL: URL,
                   to dstURL: URL)
    -> Bool { return true }
  
  static let shared = FileManagerMoveDelegate()
}

extension Path {
  /// Writes a UTF-8 string to disk without validating the encoding.
  ///
  /// - Note: This is ~15-20% faster compared to String.write(toFile:atomically:encoding:)
  ///
  /// - Parameters:
  ///   - contents: The UTF-8 string to write to disk.
  ///   - atomically: Whether to write to a temporary file first, then atomically move it to the
  ///     current path, replacing any existing file.
  /// - Throws: A `BufferedWriteFailure` if an error occurs.
  func writeUtf8String(_ contents: String, atomically: Bool = true) throws {
    guard !contents.isEmpty else { return }
    
    let tmpFilePath = (atomically ? try Path.uniqueTemporary() + lastComponent : self)
    guard let outputStream = OutputStream(toFileAtPath: "\(tmpFilePath.absolute())", append: true)
      else { throw WriteUtf8StringFailure.streamCreationFailure(path: tmpFilePath) }
    outputStream.open()
    defer { outputStream.close() }
    
    let count = contents.utf8CString.count-1 // Last character is a `Nul` character in a C string.
    guard let data = contents.utf8CString.withUnsafeBytes({
      $0.bindMemory(to: UInt8.self).baseAddress
    }) else { throw WriteUtf8StringFailure.dataEncodingFailure }
    
    let written = outputStream.write(data, maxLength: count)
    guard written > 0 else {
      throw WriteUtf8StringFailure.streamWritingFailure(error: outputStream.streamError)
    }
    
    guard atomically else { return }
    let tmpFileURL = URL(fileURLWithPath: "\(tmpFilePath.absolute())", isDirectory: false)
    let outputFileURL = URL(fileURLWithPath: "\(absolute())", isDirectory: false)
    
    FileManager.default.delegate = FileManagerMoveDelegate.shared
    _ = try FileManager.default.moveItem(at: tmpFileURL, to: outputFileURL)
  }
}

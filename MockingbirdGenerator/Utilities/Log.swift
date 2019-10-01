//
//  Log.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 9/16/19.
//

import Foundation

public enum LogType: Int, CustomStringConvertible {
  case debug = 0, warn, error
  public var description: String {
    switch self {
    case .debug: return "DEBUG"
    case .warn: return "WARN"
    case .error: return "ERROR"
    }
  }
  
  var output: UnsafeMutablePointer<FILE> {
    switch self {
    case .debug: return stdout
    case .warn: return stderr
    case .error: return stderr
    }
  }
}

public enum LogLevel {
  case normal, quiet, verbose
  func shouldLog(_ type: LogType) -> Bool {
    switch self {
    case .normal: return type.rawValue >= LogType.warn.rawValue
    case .quiet: return type.rawValue >= LogType.error.rawValue
    case .verbose: return true
    }
  }
  
  public static var `default` = Synchronized<LogLevel>(.normal)
}

private let loggingQueue = DispatchQueue(label: "co.bird.mockingbird.log", qos: .background)
public func flushLogs() {
  loggingQueue.sync {}
}

/// Log a message to `stdout` or `stderr` depending on the message severity.
public func log(_ message: @autoclosure () -> String,
                type: LogType = .debug,
                level: LogLevel = LogLevel.default.unsafeValue,
                output: UnsafeMutablePointer<FILE>? = nil,
                file: StaticString = #file,
                line: UInt = #line) {
  guard level.shouldLog(type) else { return }
  let logMessage = "[\(type)] " + message() + "\n"
  loggingQueue.async { fputs(logMessage, output ?? type.output) }
}

/// Convenience for logging a `.warn` message type
public func logWarning(_ message: @autoclosure () -> String,
                       level: LogLevel = LogLevel.default.unsafeValue,
                       output: UnsafeMutablePointer<FILE>? = nil,
                       file: StaticString = #file,
                       line: UInt = #line) {
  log(message(), type: .warn, level: level, output: output, file: file, line: line)
}

/// Convenience for logging an `.error` message type.
public func log(_ error: Error,
                level: LogLevel = LogLevel.default.unsafeValue,
                output: UnsafeMutablePointer<FILE>? = nil,
                file: StaticString = #file,
                line: UInt = #line) {
  log(error.localizedDescription, type: .error, level: level, output: output, file: file, line: line)
}

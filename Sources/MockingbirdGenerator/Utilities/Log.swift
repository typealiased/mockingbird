//
//  Log.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 9/16/19.
//

import Foundation
import PathKit

enum ControlCode: CustomStringConvertible {
  // MARK: Colors
  case red
  case green
  case yellow
  case cyan
  case white
  case black
  case grey
  
  // MARK: Misc
  case bold
  case removeFormatting
  
  /// Returns the color code which can be prefixed on a string to display it in that color.
  var description: String {
    switch self {
    case .red: return "\u{001B}[31m"
    case .green: return "\u{001B}[32m"
    case .yellow: return "\u{001B}[33m"
    case .cyan: return "\u{001B}[36m"
    case .white: return "\u{001B}[37m"
    case .black: return "\u{001B}[30m"
    case .grey: return "\u{001B}[30;1m"
    case .bold: return "\u{001B}[1m"
    case .removeFormatting: return "\u{001B}[0m"
    }
  }
}

private extension String {
  func formatted(with controlCodes: ControlCode...) -> String {
    return controlCodes.map({ "\($0)" }).joined(separator: "")
      + self
      + "\(ControlCode.removeFormatting)"
  }
}

public enum LogType: Int, CustomStringConvertible {
  case debug = 0, info, warn, error
  
  public var formattedDescription: String {
    switch self {
    case .debug, .info: return ""
    case .warn: return description.formatted(with: ControlCode.yellow, ControlCode.bold)
    case .error: return description.formatted(with: ControlCode.red, ControlCode.bold)
    }
  }
  
  public var description: String {
    switch self {
    case .debug, .info: return ""
    case .warn: return "warning:"
    case .error: return "error:"
    }
  }
  
  var output: UnsafeMutablePointer<FILE> {
    switch self {
    case .debug, .info: return stdout
    case .warn: return stderr
    case .error: return stderr
    }
  }
}

public enum LogLevel: String, RawRepresentable, CaseIterable {
  case normal = "normal"
  case quiet = "quiet"
  case verbose = "verbose"
  
  func shouldLog(_ type: LogType) -> Bool {
    switch self {
    case .normal: return type.rawValue >= LogType.info.rawValue
    case .quiet: return type.rawValue >= LogType.error.rawValue
    case .verbose: return true
    }
  }
  
  public static let `default` = Synchronized<LogLevel>(.normal)
}

public enum DiagnosticType: String, Hashable, CaseIterable {
  case all = "all"
  case notMockable = "not-mockable"
  case undefinedType = "undefined-type"
  case typeInference = "type-inference"
  
  public static let enabled = Synchronized<Set<DiagnosticType>>([])
}

public enum PruningMethod: String, Codable, CaseIterable {
  case disable = "disable"
  case stub = "stub"
  case omit = "omit"
}

private let loggingQueue = DispatchQueue(label: "co.bird.mockingbird.log", qos: .background)
public func flushLogs() {
  loggingQueue.sync {}
}

/// Log a message to `stdout` or `stderr` depending on the message severity.
public func log(_ message: @escaping @autoclosure () -> String,
                type: LogType = .debug,
                diagnostic: DiagnosticType? = nil,
                output: UnsafeMutablePointer<FILE>? = nil,
                filePath: Path? = nil,
                line: @escaping @autoclosure () -> Int? = nil) {
  loggingQueue.async {
    guard LogLevel.default.value.shouldLog(type) else { return }
    if let diagnostic = diagnostic,
      !DiagnosticType.enabled.value.contains(.all),
      !DiagnosticType.enabled.value.contains(diagnostic) { return }
    
    let locationPrefix: String
    if let filePath = filePath {
      var locationComponents = ["\(filePath.absolute())"]
      if let line = line() { locationComponents.append("\(line)") }
      locationPrefix = "\(locationComponents.joined(separator: ":")): "
    } else {
      locationPrefix = ""
    }
    
    let output = output ?? type.output
    let isTTY = isatty(fileno(output)) != 0 &&
      ProcessInfo.processInfo.environment["TERM"] != "dumb" // Terminals without color support.
    let typeDescription = isTTY ? type.formattedDescription : type.description
    let typePrefix = typeDescription + (typeDescription.isEmpty ? "" : " ")
    
    let logMessage = locationPrefix + typePrefix + message() + "\n"
    
    fputs(logMessage, output)
    fflush(output) // fputs doesn't seem to auto-flush on line breaks.
  }
}

/// Convenience for logging a `.info` message type.
public func logInfo(_ message: @escaping @autoclosure () -> String,
                    output: UnsafeMutablePointer<FILE>? = nil) {
  log(message(), type: .info, output: output)
}

/// Convenience for logging a `.warn` message type.
public func logWarning(_ message: @escaping @autoclosure () -> String,
                       diagnostic: DiagnosticType? = nil,
                       output: UnsafeMutablePointer<FILE>? = nil,
                       filePath: Path? = nil,
                       line: @escaping @autoclosure () -> Int? = nil) {
  log(message(),
      type: .warn,
      diagnostic: diagnostic,
      output: output,
      filePath: filePath,
      line: line())
}

/// Convenience for logging an `.error` message type.
public func log(_ error: Error,
                diagnostic: DiagnosticType? = nil,
                output: UnsafeMutablePointer<FILE>? = nil,
                filePath: Path? = nil,
                line: @escaping @autoclosure () -> Int? = nil) {
  log("\(error)",
      type: .error,
      diagnostic: diagnostic,
      output: output,
      filePath: filePath,
      line: line())
}

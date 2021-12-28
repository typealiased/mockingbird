import Foundation
import PathKit

public struct Subprocess: CustomStringConvertible {
  public let process: Process
  
  public let stdout = Pipe()
  public let stdin = Pipe()
  public let stderr = Pipe()
  
  public var exitStatus: Int32 { process.terminationStatus }
  
  public var workingDirectory: Path {
    Path(process.currentDirectoryURL?.path ?? FileManager.default.currentDirectoryPath)
  }
  
  public var description: String {
    "\(workingDirectory.abbreviate().string) $ \(process.arguments?.joined(separator: " ") ?? "")"
  }
  
  public init(_ command: String,
              _ arguments: [String] = [],
              workingDirectory: Path = Path.current) {
    let process = Process()
    process.launchPath = "/usr/bin/env"
    process.arguments = [command] + arguments
    process.currentDirectoryURL = workingDirectory.url
    process.qualityOfService = .userInitiated
    process.standardOutput = stdout
    process.standardInput = stdin
    process.standardError = stderr
    self.process = process
  }
  
  @discardableResult
  public func run(inBackground: Bool = false, printCommand: Bool = true) throws -> Self {
    if printCommand {
      logInfo(String(describing: self))
    }
    try process.run()
    if !inBackground {
      process.waitUntilExit()
    }
    return self
  }
  
  @discardableResult
  public func runWithOutput(inBackground: Bool = false,
                            printCommand: Bool = true) throws -> (stdout: String, stderr: String) {
    var stdoutBuffer: [String] = []
    stdout.fileHandleForReading.readabilityHandler = { pipe in
      guard let line = String(data: pipe.availableData, encoding: .utf8) else { return }
      fputs(line, Darwin.stdout)
      stdoutBuffer.append(line)
    }
    var stderrBuffer: [String] = []
    stderr.fileHandleForReading.readabilityHandler = { pipe in
      guard let line = String(data: pipe.availableData, encoding: .utf8) else { return }
      fputs(line, Darwin.stderr)
      stderrBuffer.append(line)
    }
    
    try run(inBackground: inBackground, printCommand: printCommand)
    return (stdoutBuffer.joined(separator: "\n"), stderrBuffer.joined(separator: "\n"))
  }
}

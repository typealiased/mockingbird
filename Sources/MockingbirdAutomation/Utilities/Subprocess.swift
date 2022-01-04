import Foundation
import PathKit

public struct Subprocess: CustomStringConvertible {
  enum Error: LocalizedError {
    case terminated(exitStatus: Int32)
    var errorDescription: String? {
      switch self {
      case .terminated(let exitStatus): return "Subprocess exited with code \(exitStatus)"
      }
    }
  }
  public let process: Process
  
  public let stdout = Pipe()
  public let stdin = Pipe()
  public let stderr = Pipe()
  
  public var workingDirectory: Path {
    Path(process.currentDirectoryURL?.path ?? FileManager.default.currentDirectoryPath)
  }
  
  public var description: String {
    "\(workingDirectory.abbreviate().string) $ \(process.arguments?.joined(separator: " ") ?? "")"
  }
  
  public init(_ command: String,
              _ arguments: [String] = [],
              environment: [String: String] = ProcessInfo.processInfo.environment,
              workingDirectory: Path = Path.current) {
    let process = Process()
    process.launchPath = "/usr/bin/env"
    process.arguments = [command] + arguments
    process.currentDirectoryURL = workingDirectory.url
    process.environment = environment
    process.qualityOfService = .userInitiated
    process.standardOutput = stdout
    process.standardInput = stdin
    process.standardError = stderr
    self.process = process
  }
  
  @discardableResult
  public func run(silent: Bool = false,
                  stdoutHandler: ((Data) -> Void)? = nil,
                  stderrHandler: ((Data) -> Void)? = nil) throws -> Self {
    logInfo(String(describing: self))
    
    let readabilityHandler = {
      (pipe: FileHandle, handler: ((Data) -> Void)?, output: UnsafeMutablePointer<FILE>) in
      let data = pipe.availableData
      handler?(data)
      guard !silent, let line = String(data: data, encoding: .utf8) else { return }
      fputs(line, output)
    }
    stdout.fileHandleForReading.readabilityHandler = { pipe in
      readabilityHandler(pipe, stdoutHandler, Darwin.stdout)
    }
    stderr.fileHandleForReading.readabilityHandler = { pipe in
      readabilityHandler(pipe, stderrHandler, Darwin.stderr)
    }
    
    try process.run()
    
    // Forcefully terminate the subprocess when receiving a SIGINT.
    signal(SIGINT, SIG_IGN)
    let sigintSource = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
    sigintSource.setEventHandler {
      process.terminate()
      exit(0)
    }
    defer {
      sigintSource.cancel()
      signal(SIGINT, SIG_DFL)
    }
    sigintSource.resume()

    process.waitUntilExit()
    if process.terminationStatus != 0 {
      throw Error.terminated(exitStatus: process.terminationStatus)
    }
    return self
  }
  
  public func runWithDataOutput() throws -> (stdout: Data, stderr: Data) {
    var stdoutBuffer = Data()
    var stderrBuffer = Data()
    try run(stdoutHandler: { stdoutBuffer.append($0) },
            stderrHandler: { stderrBuffer.append($0) })
    return (stdoutBuffer, stderrBuffer)
  }
  
  public func runWithStringOutput() throws -> (stdout: String, stderr: String) {
    let (stdoutBuffer, stderrBuffer) = try runWithDataOutput()
    return (String(data: stdoutBuffer, encoding: .utf8) ?? "",
            String(data: stderrBuffer, encoding: .utf8) ?? "")
  }
}

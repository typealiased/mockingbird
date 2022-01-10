import Foundation
import PathKit

struct ArgumentContext: Codable {
  let workingPath: Path
  let environment: [String: String]
  let arguments: [String]
  
  static var shared = ArgumentContext()
  
  init(workingPath: Path = Path(FileManager.default.currentDirectoryPath),
       environment: [String: String] = ProcessInfo.processInfo.environment,
       arguments: [String] = CommandLine.arguments) {
    self.workingPath = workingPath
    self.environment = environment
    self.arguments = arguments
  }
}

protocol InferableArgument {
  init?(context: ArgumentContext) throws
}

func inferArgument<T: InferableArgument>(_ argument: T?,
                                         in context: ArgumentContext = .shared) throws -> T? {
  guard argument == nil else {
    return argument
  }
  return try T(context: context)
}

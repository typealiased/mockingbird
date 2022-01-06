import ArgumentParser
import Foundation
import MockingbirdGenerator
import PathKit

struct BinaryPath: ExpressibleByArgument {
  var path: Path
  var defaultValueDescription: String { path.abbreviate().string }
  static var defaultCompletionKind: CompletionKind = .file()
  
  init?(argument: String) {
    self.path = Path(argument)
  }
}

extension BinaryPath: Encodable {
  func encode(to encoder: Encoder) throws {
    try OptionArgumentEncoding.encode(path, with: encoder)
  }
}

extension BinaryPath: InferableArgument {
  init?(context: ArgumentContext) throws {
    let launcherPath = context.environment["MKB_LAUNCHER"]
    let realBinaryPath = context.arguments[0]
    self.path = Path(launcherPath ?? realBinaryPath)
  }
}

extension BinaryPath: ValidatableArgument {
  func validate(name: String) throws {
    let realPath = try path.followRecursively()
    guard realPath.isExecutable else {
      throw ValidationError("'\(name)' must be executable")
    }
  }
}

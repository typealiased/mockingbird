import Foundation
import MockingbirdCommon
import MockingbirdGenerator

do {
  defer { flushLogs() }
  var command = try Mockingbird.parseAsRoot()
  try command.run()
} catch {
  Mockingbird.exit(withError: error)
}

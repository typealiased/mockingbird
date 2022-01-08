import Foundation
import MockingbirdGenerator

do {
  defer { flushLogs() }
  var command = try Mockingbird.parseAsRoot()
  try command.run()
} catch {
  Mockingbird.exit(withError: error)
}

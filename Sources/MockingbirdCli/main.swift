import Foundation
import MockingbirdGenerator

func main() -> Int32 {
  defer { flushLogs() }
  do {
    var command = try Mockingbird.parseAsRoot()
    try command.run()
    return 0
  } catch {
    logError(error)
    return 1
  }
}

exit(main())

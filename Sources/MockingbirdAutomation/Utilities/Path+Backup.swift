import Foundation
import PathKit

public extension Path {
  func backup(fileExtension: String = "bak") throws {
    let backupPath = Path(absolute().string + "." + fileExtension)
    try? backupPath.delete()
    try copy(backupPath)
  }
  
  func restore(fileExtension: String = "bak") throws {
    let copy = Path(absolute().string)
    try? copy.delete()
    try Path(absolute().string + "." + fileExtension).move(self)
  }
}

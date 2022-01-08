import Foundation
import PathKit
import MockingbirdGenerator

extension Path {
  func abbreviated(style: SubstitutionStyle = .bash) -> String {
    let abbreviated = absolute().abbreviate().string
    guard abbreviated.starts(with: "~") else { return abbreviated }
    return style.wrap("HOME") + abbreviated.dropFirst()
  }
  
  func abbreviated(root: Path,
                   variable: String,
                   style: SubstitutionStyle = .bash) -> String {
    let absoluteSelfPath = absolute().string
    let absoluteRootPath = root.absolute().string
    let relativePath = abbreviated()
    guard absoluteSelfPath.starts(with: absoluteRootPath) else {
      return relativePath
    }
    return style.wrap(variable) + absoluteSelfPath.dropFirst(absoluteRootPath.count)
  }
}

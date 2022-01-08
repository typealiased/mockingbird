import Foundation

public extension String {
  /// Returns all matches and capture groups given a regex pattern. First element is the full match.
  func components(matching pattern: String) -> [[Substring]] {
    guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
    return regex
      .matches(in: self, range: NSMakeRange(0, count))
      .map({ result -> [Substring] in
        return (0..<result.numberOfRanges)
          .map({ index -> NSRange in result.range(at: index) })
          .filter({ range -> Bool in range.location != NSNotFound })
          .compactMap({ range -> Range<Index>? in Range(range, in: self) })
          .map({ range -> Substring in self[range] })
      })
  }
}

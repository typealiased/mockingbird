import Foundation

struct BlockTemplate: Template {
  let body: String
  let multiline: Bool
  let indented: Bool
  
  init(body: String, multiline: Bool = true, indented: Bool = true) {
    self.body = body
    self.multiline = multiline
    self.indented = indented
  }
  
  func render() -> String {
    if multiline {
      return String(lines: [
        "{",
        indented ? body.indent() : body,
        "}"
      ])
    } else {
      return "{ " + body + " }"
    }
  }
}

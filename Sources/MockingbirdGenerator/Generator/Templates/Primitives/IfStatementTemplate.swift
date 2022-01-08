import Foundation

struct IfStatementTemplate: Template {
  let condition: String
  let body: String
  
  init(condition: String, body: String) {
    self.condition = condition
    self.body = body
  }
  
  func render() -> String {
    return "if \(condition) " + BlockTemplate(body: body, multiline: false).render()
  }
}

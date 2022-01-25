import Foundation

class RenderTemplateOperation: Runnable {
  let template: Template
  
  class Result {
    fileprivate(set) var renderedContents = ""
  }
  
  let result = Result()
  var description: String { "Render Template" }
  
  init(template: Template) {
    self.template = template
  }
  
  func run(context: RunnableContext) {
    result.renderedContents = template.render()
  }
}

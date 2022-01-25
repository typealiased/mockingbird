import XCTest
@testable import MockingbirdGenerator

class ActionGraphTests: XCTestCase {
  var actionGraph: ActionGraph!
  
  override func setUp() {
    self.actionGraph = ActionGraph()
  }
  
  class FakeOperation: Runnable {
    var description: String { "Fake" }
    let expectation: XCTestExpectation
    init(shouldRun: Bool = true) {
      let expectation = XCTestExpectation(description: "Fake operation")
      expectation.isInverted = !shouldRun
      self.expectation = expectation
    }
    func run(context: RunnableContext) throws {
      expectation.fulfill()
    }
  }
  
  func testTrivialNode() {
    //
    //  A
    //
    let operationA = FakeOperation()
    actionGraph.register(operationA)
    actionGraph.runAndWait(for: [operationA])
  }
  
  func testNodeWithSingleDependency() {
    //  B
    //  |
    //  A
    let operationA = FakeOperation()
    let operationB = FakeOperation()
    actionGraph.register(operationA, dependencies: [operationB])
    actionGraph.runAndWait(for: [operationA])
  }
  
  func testNodeWithMultipleDependencies() {
    //  B   C
    //   \ /
    //    A
    let operationA = FakeOperation()
    let operationB = FakeOperation()
    let operationC = FakeOperation()
    actionGraph.register(operationA, dependencies: [operationB, operationC])
    actionGraph.runAndWait(for: [operationA])
  }
  
  func testNodeWithMultipleDependants() {
    //    A
    //   / \
    //  B   C
    let operationA = FakeOperation()
    let operationB = FakeOperation()
    let operationC = FakeOperation()
    actionGraph.register(operationA)
    actionGraph.register(operationB, dependencies: [operationA])
    actionGraph.register(operationC, dependencies: [operationA])
    actionGraph.runAndWait(for: [operationB, operationC])
  }
  
  func testMultipleDisconnectedSubgraphs() {
    //  A'  B'
    //  |   |
    //  A   B
    let operationA = FakeOperation()
    let operationADep = FakeOperation()
    actionGraph.register(operationA, dependencies: [operationADep])
    
    let operationB = FakeOperation()
    let operationBDep = FakeOperation()
    actionGraph.register(operationB, dependencies: [operationBDep])
    
    actionGraph.runAndWait(for: [operationA, operationB])
  }
  
}

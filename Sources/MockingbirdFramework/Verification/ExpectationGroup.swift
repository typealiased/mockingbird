import Foundation

/// A deferred expectation that can be fulfilled when an invocation arrives later.
struct CapturedExpectation {
  let mockingContext: MockingContext
  let invocation: Invocation
  let expectation: Expectation
}

/// Stores all expectations invoked by verification methods within a scoped context.
class ExpectationGroup {
  static let contextKey = DispatchSpecificKey<ExpectationGroup>()
  
  private(set) weak var parent: ExpectationGroup?
  private let verificationBlock: (ExpectationGroup) throws -> Void
  
  init(_ verificationBlock: @escaping (ExpectationGroup) throws -> Void) {
    self.parent = DispatchQueue.currentExpectationGroup
    self.verificationBlock = verificationBlock
  }
  
  struct Failure: Error {
    let error: TestFailure
    let sourceLocation: SourceLocation
  }

  func verify(context: ExpectationGroup? = nil) throws {
    if let parent = parent, context == nil {
      parent.addSubgroup(self)
    } else {
      try verificationBlock(self)
    }
  }
  
  private(set) var expectations = [CapturedExpectation]()
  func addExpectation(mockingContext: MockingContext,
                      invocation: Invocation,
                      expectation: Expectation) {
    expectations.append(CapturedExpectation(mockingContext: mockingContext,
                                            invocation: invocation,
                                            expectation: expectation))
  }
  
  private(set) var subgroups = [ExpectationGroup]()
  func addSubgroup(_ subgroup: ExpectationGroup) {
    subgroups.append(subgroup)
  }
  
  func countExpectations() -> Int {
    return expectations.count + subgroups.reduce(into: 0) { count, subgroup in
      count += subgroup.countExpectations()
    }
  }
}

extension DispatchQueue {
  class var currentExpectationGroup: ExpectationGroup? {
    return DispatchQueue.getSpecific(key: ExpectationGroup.contextKey)
  }
}

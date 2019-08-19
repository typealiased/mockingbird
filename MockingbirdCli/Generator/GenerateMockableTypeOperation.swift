//
//  GenerateMockableTypeOperation.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/18/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation

class MemoizedContainer {
  var variables = Synchronized<[Variable: String]>([:])
  var methods = Synchronized<[Method: String]>([:])
}

class GenerateMockableTypeOperation: BasicOperation {
  let mockableType: MockableType
  let memoizedContainer: MemoizedContainer
  var memoizedVariables: [Variable: String]
  var memoizedMethods: [Method: String]
  
  class Result {
    fileprivate(set) var generatedContents = ""
  }
  
  let result = Result()
  
  init(mockableType: MockableType, memoizedContainer: MemoizedContainer) {
    self.mockableType = mockableType
    self.memoizedContainer = memoizedContainer
    self.memoizedVariables = memoizedContainer.variables.value
    self.memoizedMethods = memoizedContainer.methods.value
  }
  
  override func run() {
    result.generatedContents = mockableType.generate(memoizedVariables: &memoizedVariables,
                                                     memoizedMethods: &memoizedMethods)
    let mergeStrategy = { (lhs: String, _: String) -> String in
      return lhs // lhs should always equal rhs
    }
    memoizedContainer.variables.update { $0.merge(self.memoizedVariables,
                                                  uniquingKeysWith: mergeStrategy) }
    memoizedContainer.methods.update { $0.merge(self.memoizedMethods,
                                                uniquingKeysWith: mergeStrategy) }
  }
}

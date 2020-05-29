//
//  KeywordArgumentNames.swift
//  MockingbirdTestsHost
//
//  Created by Ryan Meisters on 2/9/20.
//  Copyright © 2020 Bird Rides, Inc. All rights reserved.
//

import Foundation

protocol KeywordArgNamesProtocol {
  func methodWithKeywordParam(`inout`: String)
  func methodWithNamedKeywordParam(with `inout`: String)
  func methodWithUnnamedKeywordParam(_ `inout`: String)
  func methodWithParamNamedKeyword(`inout` param: String)
}

class KeywordArgNamesClass {
  func methodWithKeywordParam(`inout`: String) {}
  func methodWithNamedKeywordParam(with `inout`: String) {}
  func methodWithUnnamedKeywordParam(_ `inout`: String) {}
  func methodWithParamNamedKeyword(`inout` param: String) {}
}

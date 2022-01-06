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

import Foundation

protocol SubscriptedProtocol {
  subscript(index: Int) -> String { get set }
  subscript(index: Int) -> Bool { get set } // Overloaded parameter type
  subscript(index: String) -> String { get set } // Overloaded return type
  subscript(object: AnyObject) -> Int { get } // Only getter
  subscript(row: Int, column: Int) -> String { get set } // Multiple parameters
  subscript(indexes: String...) -> String { get set } // Variadic parameter
  subscript<IndexType: Equatable, ReturnType: Hashable>(index: IndexType) -> ReturnType { get set }
}

class SubscriptedClass {
  subscript(index: Int) -> String {
    get { fatalError() }
    set { fatalError() }
  }
  
  // Overloaded parameter type
  subscript(index: Int) -> Bool {
    get { fatalError() }
    set { fatalError() }
  }
  
  // Overloaded return type
  subscript(index: String) -> String {
    get { fatalError() }
    set { fatalError() }
  }
  
  // Only getter
  subscript(object: AnyObject) -> Int {
    get { fatalError() }
  }
  
  // Private setter
  private(set) subscript(object: NSObject) -> Int {
    get { fatalError() }
    set { fatalError() }
  }
  
  // Multiple parameters
  subscript(row: Int, column: Int) -> String {
    get { fatalError() }
    set { fatalError() }
  }
  
  // Variadic parameter
  subscript(indexes: String...) -> String {
    get { fatalError() }
    set { fatalError() }
  }
  
  // Generics
  subscript<IndexType: Equatable, ReturnType: Hashable>(index: IndexType) -> ReturnType {
    get { fatalError() }
    set { fatalError() }
  }
}

@dynamicMemberLookup
class DynamicMemberLookupClass {
  subscript(dynamicMember member: String) -> Int {
    get { fatalError() }
    set { fatalError() }
  }
}

@dynamicMemberLookup
class GenericDynamicMemberLookupClass {
  subscript<T>(dynamicMember member: String) -> T {
    get { fatalError() }
    set { fatalError() }
  }
}

import Foundation

#if swift(>=5.5.2)
protocol AsyncProtocol {  
  @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
  func asyncMethodVoid() async
  
  @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
  func asyncMethod() async -> Bool
  
  @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
  func asyncMethod(parameter: String) async -> Int
  
  @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
  func asyncThrowingMethod() async throws -> Int
  
  @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
  func asyncClosureMethod(block: () async -> Bool) async
  
  @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
  func asyncClosureThrowingMethod(block: () async throws -> Bool) async throws -> Bool
}

class AsyncClass {
  @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
  func asyncMethodVoid() async { fatalError() }
  
  @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
  func asyncMethod() async -> Bool  { fatalError() }
  
  @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
  func asyncMethod(parameter: String) async -> Int  { fatalError() }
  
  @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
  func asyncThrowingMethod() async throws -> Int  { fatalError() }
  
  @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
  func asyncClosureMethod(block: () async -> Bool) async  { fatalError() }
  
  @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
  func asyncClosureThrowingMethod(block: () async throws -> Bool) async throws -> Bool {
    fatalError()
  }
  
  // Test for false positives.
  func notAsync() {
    DispatchQueue.main.async {}
  }
}
#endif

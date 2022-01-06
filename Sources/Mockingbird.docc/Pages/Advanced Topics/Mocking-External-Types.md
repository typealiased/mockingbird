# Mocking External Types

Create test doubles for external types without sources.

## Overview

Swift types imported from a library or framework that you don’t have source access to cannot be mocked by Mockingbird. These are considered opaque external types and require source changes to generate mocks. In the future, this process will be improved to allow generating mocks from <doc:Supporting-Source-Files>.

> Note: Mockingbird supports external Objective-C types out of the box because they are dynamically created at run time instead of at compile time like Swift.

## Caveat

There’s a saying that’s passed around the testing circles: “Don't mock what you don't own.” The key idea here is that mocking or stubbing is best done on types that allow you to make assumptions about its behavior. Since external types can change without any consideration for your mocks and stubs, they should be treated as opaque and left to integration style tests.

That said, this isn’t a hard and fast rule; sometimes it’s simply easier to mock external types.

### Walkthrough

As an example, let’s mock `URLSession` which is used by a class we want to test called `CarrierPigeon`.

```swift
class CarrierPigeon {
  func sendMessage(session: URLSession) {
    session.dataTask(with: URL(string: "http://bird.co")!).resume()
  }
}
```

First, declare a protocol with all relevant methods and conform the external type to the protocol. In this case, we will declare `BirdURLSession` and conform `URLSession` to the protocol using an extension.

```swift
protocol BirdURLSession {
  func dataTask(with url: URL) -> URLSessionDataTask
}
extension URLSession: BirdURLSession {}
```

Next, replace usages of the original external type with the new protocol. We will update `CarrierPigeon` to use `BirdURLSession` instead.

```swift
class CarrierPigeon {
  func sendMessage(session: BirdURLSession) {
    session.dataTask(with: URL(string: "http://bird.co")!).resume()
  }
}
```

After applying the same steps to `URLSessionDataTask`, we can now test sending a message with `CarrierPigeon`.

```swift
func testSendMessage() {
  // Given
  let session = mock(BirdURLSession.self)
  let dataTask = mock(BirdURLSessionDataTask.self)
  given(session.dataTask(with: any())).willReturn(dataTask)

  // When
  CarrierPigeon().sendMessage(session: session)

  // Then
  verify(session.dataTask(with: any())).wasCalled()
  verify(dataTask.resume()).wasCalled()
}
```

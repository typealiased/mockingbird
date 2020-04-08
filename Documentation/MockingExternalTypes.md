# Mocking External Types

## A Word of Caution

There’s a saying that’s passed around the testing circles: “Don't mock what you don't own.” The key idea here is that
mocking or stubbing is best done on types that allow you to make assumptions about its behavior. Since external
types can change without any consideration for your mocks and stubs, they should be treated as opaque and left to
integration style tests. 

That said, this isn’t a hard and fast rule; sometimes it’s simply easier to mock external types.

## Recommended Approach

Let’s mock `URLSession` which is used by a class we want to test called `CarrierPigeon`.

```swift
class CarrierPigeon {
  let session: URLSession
  
  init(with session: URLSession) {
    self.session = session
  }
  
  func sendMessage() {
    session.dataTask(with: URL(string: "example.com")!).resume()
  }
}
```

### Conform the Type to a Protocol

Declare a protocol with all relevant methods and conform the external type to the protocol. In this case, we will
declare `BirdURLSession` and conform `URLSession` to the protocol using an extension.

```swift
protocol BirdURLSession {
  func dataTask(with url: URL) -> URLSessionDataTask
}
extension URLSession: BirdURLSession {}
```

### Update Existing References

Replace usages of the original external type with the new protocol. We will update `CarrierPigeon` to use
`BirdURLSession` instead.

```swift
class CarrierPigeon {
  let session: BirdURLSession
  
  init(with session: BirdURLSession) {
    self.session = session
  }
  
  func sendMessage() {
    session.dataTask(with: URL(string: "example.com")!).resume()
  }
}
```

### Write Tests

Assuming the same steps were applied to `URLSessionDataTask`, Mockingbird will now generate mocks that can
be used to test sending a message with `CarrierPigeon`.

```swift
func testSendMessage() {
  // Given
  let session = mock(BirdURLSession.self)
  let dataTask = mock(BirdURLSessionDataTask.self)
  let pigeon = CarrierPigeon(with: session)
  given(session.dataTask(with: any())) ~> dataTask
  
  // When
  pigeon.sendMessage()
  
  // Then
  verify(session.dataTask(with: any())).wasCalled()
  verify(dataTask.resume()).wasCalled()
}
```

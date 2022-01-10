#import <XCTest/XCTest.h>

NS_ASSUME_NONNULL_BEGIN

/// An expected outcome in an asynchronous test.
///
/// Library evolution as of Swift 5.5.2 breaks when publicly including any types from the `XCTest`
/// framework due to the `XCTest` class declaration. Using a bridged type that can be casted to and
/// from `XCTestExpectation` allows us to avoid a direct reference in the Swift module interface.
/// See https://github.com/birdrides/mockingbird/issues/242 for more information.
NS_SWIFT_NAME(TestExpectation)
@interface MKBTestExpectation : XCTestExpectation

/// Convert an `XCTestExpectation` to a `MKBTestExpectation`.
/// @param expectation An `XCTestExpectation` instance.
+ (instancetype)createFromExpectation:(XCTestExpectation *)expectation;

@end

NS_ASSUME_NONNULL_END

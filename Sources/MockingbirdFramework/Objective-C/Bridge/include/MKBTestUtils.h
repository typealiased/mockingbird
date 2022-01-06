#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

void MKBStopTest(NSString *reason);

void MKBThrowException(NSException *reason);

NSException *_Nullable MKBTryBlock(void(^_Nonnull NS_NOESCAPE block)(void));

/// Returns `true` if the value is equal to `NSNull`.
///
/// @param value The value to check.
///
/// Fully type erased optionals in Swift causes typical `nil` checks to fail. For example:
///
/// ```swift
/// func erase<T>(_ value: T) {
///   print(value == nil)                       // false
///   print(value as Optional<Any> == nil)      // false
///   print(value as? Optional<String> == nil)  // false
///   print(value as! Optional<String> == nil)  // true
/// }
/// erase(Optional<String>(nil))
/// ```
///
/// Since Objective-C implicitly bridges to `NSNull`, an easy (albeit hacky) way to check if the
/// value is both an `Optional` and `nil` at runtime is to pass it Objective-C. Swift does support
/// referencing the `NSNull` instance, so callers need to check if the value is actually `NSNull` on
/// the Swift side.
bool MKBCheckIfTypeErasedNil(id _Nullable value);

NS_ASSUME_NONNULL_END

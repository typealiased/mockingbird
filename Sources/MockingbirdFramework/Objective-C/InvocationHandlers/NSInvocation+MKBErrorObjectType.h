#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSInvocation (MKBErrorObjectType)

/// Check if the parameter is likely a returned error object.
///
/// `NSError **` type arguments are converted to throwing methods in Swift which cannot be matched.
/// It's necessary to check whether the pointer is (likely) to a returned error object and use a
/// wildcard argument matcher instead.
///
/// See also: "Creating and Returning NSError Objects" in Apple's documentation archive.
- (BOOL)isErrorArgumentTypeAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END

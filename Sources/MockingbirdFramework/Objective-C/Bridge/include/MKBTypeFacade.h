#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MKBConcreteMock;

@interface MKBTypeFacade<T> : NSProxy

@property (nonatomic, strong, readonly) id mkb_boxedObject;
@property (nonatomic, strong, readonly) MKBConcreteMock *mkb_mock;

/// Used to check whether an instance is a type facade.
/// Callers can just check whether the instance responds to the `mkb_isTypeFacade` selector and
/// ignore the value of this property.
@property (nonatomic, assign, readonly) bool mkb_isTypeFacade;

- (instancetype)initWithMock:(id)mock object:(id)object NS_DESIGNATED_INITIALIZER;
- (T)fixupType;

/// Used from Swift to coerce a test double into an arbitrary type.
/// @param object A test double object.
+ (T)createFromObject:(id)object;

@end

NS_ASSUME_NONNULL_END

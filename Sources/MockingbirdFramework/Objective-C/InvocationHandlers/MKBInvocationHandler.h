#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MKBArgumentMatcher;

@protocol MKBInvocationHandlerType <NSObject>

/// Create an argument matcher from a specific argument of an invocation.
/// @param index The index of the argument that should be serialized.
/// @param invocation An invocation with arguments.
/// @return An argument matcher serialized from the invocation argument.
- (MKBArgumentMatcher *)serializeArgumentAtIndex:(NSUInteger)index
                                   forInvocation:(NSInvocation *)invocation;

/// Set the return value for an invocation.
/// @param returnValue A boxed return value.
- (void)deserializeReturnValue:(id)returnValue forInvocation:(NSInvocation *)invocation;

@end

@interface MKBInvocationHandler : NSObject <MKBInvocationHandlerType>

/// The next invocation handler that should receive unhandled requests.
@property (nonatomic, strong, readwrite) MKBInvocationHandler *_Nullable next;

/// The encoded Objective-C type that this handler accepts.
@property (nonatomic, assign, readonly) const char *objCType;

/// An optional selector that boxed values must respond to.
@property (nonatomic, assign, readonly) SEL deserializationSelector;

- (instancetype)initWithNext:(MKBInvocationHandler *_Nullable)next;
- (instancetype)initWithObjCType:(const char *)objCType
                            next:(MKBInvocationHandler *_Nullable)next
                        selector:(SEL)selector;
- (instancetype)init NS_UNAVAILABLE;

- (BOOL)canSerializeArgumentAtIndex:(NSUInteger)index forInvocation:(NSInvocation *)invocation;
- (BOOL)canDeserializeReturnValue:(id)returnValue forInvocation:(NSInvocation *)invocation;

@end

NS_ASSUME_NONNULL_END

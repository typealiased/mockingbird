//
//  MKBPointerInvocationHandler.m
//  MockingbirdFramework
//
//  Created by typealias on 7/19/21.
//

#import "MKBPointerInvocationHandler.h"
#import "MKBComparator.h"
#import <Mockingbird/Mockingbird-Swift.h>

@implementation MKBPointerInvocationHandler

- (instancetype)initWithNext:(MKBInvocationHandler *)next
{
  return (self = [super initWithObjCType:@encode(void *)
                                    next:next
                                selector:@selector(pointerValue)]);
}

/// Attempt to serialize the argument as an error object.
///
/// `NSError **` type arguments are converted to throwing methods in Swift which cannot be matched.
/// It's necessary to check whether the pointer is (likely) to a returned error object and use a
/// wildcard argument matcher instead.
///
/// See also: "Creating and Returning NSError Objects" in Apple's documentation archive.
- (MKBArgumentMatcher *_Nullable)serializeErrorArgumentAtIndex:(NSUInteger)index
                                                 forInvocation:(NSInvocation *)invocation
                                                     withValue:(void *)value
{
  const NSMethodSignature *methodSignature = invocation.methodSignature;
  const BOOL isLastArgument = (index == methodSignature.numberOfArguments-1);
  const BOOL isVoidReturnType = (methodSignature.methodReturnType[0] == @encode(void)[0]);
  if (!isLastArgument || isVoidReturnType) {
    return nil;
  }
  
  const size_t normalizedIndex = index-2; // self, _cmd
  const NSArray<NSString *> *components =
    [NSStringFromSelector(invocation.selector) componentsSeparatedByString:@":"];
  if (normalizedIndex >= components.count) {
    return nil;
  }
  
  const NSString *parameterName = components[normalizedIndex];
  if (![parameterName.lowercaseString containsString:@"error"]) { // Heuristic
    return nil;
  }
  
  NSString *description = [NSString stringWithFormat:@"%p (thrown error object)", value];
  return [[MKBArgumentMatcher alloc] init:[NSValue valueWithPointer:value]
                              description:description
                               comparator:MKBAnyComparator];
}

- (MKBArgumentMatcher *)serializeArgumentAtIndex:(NSUInteger)index
                                   forInvocation:(NSInvocation *)invocation
{
  void *value;
  [invocation getArgument:&value atIndex:index];
  
  MKBArgumentMatcher *_Nullable errorArgumentMatcher =
    [self serializeErrorArgumentAtIndex:index forInvocation:invocation withValue:value];
  if (errorArgumentMatcher) {
    return errorArgumentMatcher;
  }
  
  return [[MKBArgumentMatcher alloc] init:[NSValue valueWithPointer:value]
                              description:[NSString stringWithFormat:@"%p", value]
                               comparator:MKBEquatableComparator];
}

- (void)deserializeReturnValue:(id)returnValue forInvocation:(NSInvocation *)invocation
{
  void *value = [returnValue pointerValue];
  [invocation setReturnValue:&value];
}

@end

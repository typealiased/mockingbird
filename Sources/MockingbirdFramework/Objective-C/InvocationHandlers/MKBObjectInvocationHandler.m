#import "MKBObjectInvocationHandler.h"
#import "MKBComparator.h"
#if MKB_SWIFTPM
@import Mockingbird;
@import MockingbirdBridge;
#else
#import <Mockingbird/Mockingbird-Swift.h>
#import <Mockingbird/MKBTypeFacade.h>
#endif

@implementation MKBObjectInvocationHandler

- (instancetype)initWithNext:(MKBInvocationHandler *)next
{
  return (self = [super initWithObjCType:@encode(id) next:next selector:@selector(class)]);
}

- (MKBArgumentMatcher *)serializeArgumentAtIndex:(NSUInteger)index
                                   forInvocation:(NSInvocation *)invocation
{
  __unsafe_unretained id value = nil;
  [invocation getArgument:&value atIndex:index];
  
  // Unwrapped boxed types within type facades.
  if ([value respondsToSelector:@selector(mkb_isTypeFacade)]) {
    value = ((MKBTypeFacade *)value).mkb_boxedObject;
  }
  
  // Use argument matchers directly.
  if ([value isKindOfClass:[MKBArgumentMatcher class]]) {
    return (MKBArgumentMatcher *)value;
  }
  
  NSString *_Nullable description = nil;
  if ([value respondsToSelector:@selector(description)]) description = [value description];
  return [[MKBArgumentMatcher alloc] init:value
                              description:description
                               comparator:MKBEquatableComparator];
}

- (void)deserializeReturnValue:(id)returnValue forInvocation:(NSInvocation *)invocation
{
  // Handle nil values from Swift.
  if ([returnValue isKindOfClass:[MKBNilValue class]]) {
    id _Nullable nilReturnValue = nil;
    [invocation setReturnValue:&nilReturnValue];
    return;
  }
  
  [invocation setReturnValue:&returnValue];
}

@end

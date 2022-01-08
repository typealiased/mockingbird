#import "MKBCStringInvocationHandler.h"
#import "MKBComparator.h"
#if MKB_SWIFTPM
@import Mockingbird;
#else
#import <Mockingbird/Mockingbird-Swift.h>
#endif

@implementation MKBCStringInvocationHandler

- (instancetype)initWithNext:(MKBInvocationHandler *)next
{
  return (self = [super initWithObjCType:@encode(char *)
                                    next:next
                                selector:@selector(stringValue)]);
}

- (MKBArgumentMatcher *)serializeArgumentAtIndex:(NSUInteger)index
                                   forInvocation:(NSInvocation *)invocation
{
  char *value;
  [invocation getArgument:&value atIndex:index];
  NSString *description = [NSString stringWithUTF8String:value];
  return [[MKBArgumentMatcher alloc] init:description
                              description:description
                               comparator:MKBEquatableComparator];
}

- (void)deserializeReturnValue:(id)returnValue forInvocation:(NSInvocation *)invocation
{
  char *value = (char *)[[returnValue stringValue] UTF8String];
  [invocation setReturnValue:&value];
}

@end

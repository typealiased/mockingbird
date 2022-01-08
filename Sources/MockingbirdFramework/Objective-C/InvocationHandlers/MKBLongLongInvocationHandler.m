#import "MKBLongLongInvocationHandler.h"
#import "MKBComparator.h"
#if MKB_SWIFTPM
@import Mockingbird;
#else
#import <Mockingbird/Mockingbird-Swift.h>
#endif

@implementation MKBLongLongInvocationHandler

- (instancetype)initWithNext:(MKBInvocationHandler *)next
{
  return (self = [super initWithObjCType:@encode(long long)
                                    next:next
                                selector:@selector(longLongValue)]);
}

- (MKBArgumentMatcher *)serializeArgumentAtIndex:(NSUInteger)index
                                   forInvocation:(NSInvocation *)invocation
{
  long long value;
  [invocation getArgument:&value atIndex:index];
  return [[MKBArgumentMatcher alloc] init:@(value)
                              description:[NSString stringWithFormat:@"%lld", value]
                               comparator:MKBEquatableComparator];
}

- (void)deserializeReturnValue:(id)returnValue forInvocation:(NSInvocation *)invocation
{
  long long value = [returnValue longLongValue];
  [invocation setReturnValue:&value];
}

@end

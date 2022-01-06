#import "MKBSelectorInvocationHandler.h"
#import "MKBComparator.h"
#if MKB_SWIFTPM
@import Mockingbird;
#else
#import <Mockingbird/Mockingbird-Swift.h>
#endif

@implementation MKBSelectorInvocationHandler

- (instancetype)initWithNext:(MKBInvocationHandler *)next
{
  return (self = [super initWithObjCType:@encode(SEL) next:next selector:@selector(stringValue)]);
}

- (MKBArgumentMatcher *)serializeArgumentAtIndex:(NSUInteger)index
                                   forInvocation:(NSInvocation *)invocation
{
  SEL value;
  [invocation getArgument:&value atIndex:index];
  NSString *description = NSStringFromSelector(value);
  return [[MKBArgumentMatcher alloc] init:description
                              description:description
                               comparator:MKBEquatableComparator];
}

- (void)deserializeReturnValue:(id)returnValue forInvocation:(NSInvocation *)invocation
{
  SEL value = NSSelectorFromString([returnValue stringValue]);
  [invocation setReturnValue:&value];
}


@end

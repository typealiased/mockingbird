//
//  MKBDoubleInvocationHandler.m
//  MockingbirdFramework
//
//  Created by typealias on 7/19/21.
//

#import "MKBDoubleInvocationHandler.h"
#import "MKBComparator.h"
#if MKB_SWIFTPM
@import Mockingbird;
#else
#import <Mockingbird/Mockingbird-Swift.h>
#endif

@implementation MKBDoubleInvocationHandler

- (instancetype)initWithNext:(MKBInvocationHandler *)next
{
  return (self = [super initWithObjCType:@encode(double)
                                    next:next
                                selector:@selector(doubleValue)]);
}

- (MKBArgumentMatcher *)serializeArgumentAtIndex:(NSUInteger)index
                                   forInvocation:(NSInvocation *)invocation
{
  double value;
  [invocation getArgument:&value atIndex:index];
  return [[MKBArgumentMatcher alloc] init:@(value)
                              description:[NSString stringWithFormat:@"%lf", value]
                               comparator:MKBEquatableComparator];
}

- (void)deserializeReturnValue:(id)returnValue forInvocation:(NSInvocation *)invocation
{
  double value = [returnValue doubleValue];
  [invocation setReturnValue:&value];
}

@end

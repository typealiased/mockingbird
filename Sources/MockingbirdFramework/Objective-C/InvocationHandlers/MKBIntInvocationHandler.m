//
//  MKBIntInvocationHandler.m
//  MockingbirdFramework
//
//  Created by typealias on 7/19/21.
//

#import "MKBIntInvocationHandler.h"
#import "MKBComparator.h"
#import <Mockingbird/Mockingbird-Swift.h>

@implementation MKBIntInvocationHandler

- (instancetype)initWithNext:(MKBInvocationHandler *)next
{
  return (self = [super initWithObjCType:@encode(int) next:next]);
}

- (MKBArgumentMatcher *)serializeArgumentAtIndex:(NSUInteger)index
                                   forInvocation:(NSInvocation *)invocation
{
  int value;
  [invocation getArgument:&value atIndex:index];
  return [[MKBArgumentMatcher alloc] init:@(value)
                              description:[NSString stringWithFormat:@"%d", value]
                               comparator:MKBEquatableComparator];
}

- (void)deserializeReturnValue:(id)returnValue forInvocation:(NSInvocation *)invocation
{
  long value = [returnValue longValue];
  [invocation setReturnValue:&value];
}

@end

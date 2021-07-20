//
//  MKBUnsignedIntInvocationHandler.m
//  MockingbirdFramework
//
//  Created by typealias on 7/19/21.
//

#import "MKBUnsignedIntInvocationHandler.h"
#import "MKBComparator.h"
#import <Mockingbird/Mockingbird-Swift.h>

@implementation MKBUnsignedIntInvocationHandler

- (instancetype)initWithNext:(MKBInvocationHandler *)next
{
  return (self = [super initWithObjCType:@encode(unsigned int) next:next]);
}

- (MKBArgumentMatcher *)serializeArgumentAtIndex:(NSUInteger)index
                                   forInvocation:(NSInvocation *)invocation
{
  unsigned int value;
  [invocation getArgument:&value atIndex:index];
  return [[MKBArgumentMatcher alloc] init:@(value)
                              description:[NSString stringWithFormat:@"%d", value]
                               comparator:MKBEquatableComparator];
}

- (void)deserializeReturnValue:(id)returnValue forInvocation:(NSInvocation *)invocation
{
  unsigned int value = [returnValue unsignedIntValue];
  [invocation setReturnValue:&value];
}

@end

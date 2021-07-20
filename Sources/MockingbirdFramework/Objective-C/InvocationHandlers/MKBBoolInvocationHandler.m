//
//  MKBBoolInvocationHandler.m
//  MockingbirdFramework
//
//  Created by typealias on 7/19/21.
//

#import "MKBBoolInvocationHandler.h"
#import "MKBComparator.h"
#import <Mockingbird/Mockingbird-Swift.h>

@implementation MKBBoolInvocationHandler

- (instancetype)initWithNext:(MKBInvocationHandler *)next
{
  return (self = [super initWithObjCType:@encode(BOOL) next:next]);
}

- (MKBArgumentMatcher *)serializeArgumentAtIndex:(NSUInteger)index
                                   forInvocation:(NSInvocation *)invocation
{
  BOOL value;
  [invocation getArgument:&value atIndex:index];
  return [[MKBArgumentMatcher alloc] init:@(value)
                              description:value ? @"YES" : @"NO"
                               comparator:MKBEquatableComparator];
}

- (void)deserializeReturnValue:(id)returnValue forInvocation:(NSInvocation *)invocation
{
  BOOL value = [returnValue boolValue];
  [invocation setReturnValue:&value];
}

@end

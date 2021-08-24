//
//  MKBUnsignedCharInvocationHandler.m
//  MockingbirdFramework
//
//  Created by typealias on 7/19/21.
//

#import "MKBUnsignedCharInvocationHandler.h"
#import "MKBComparator.h"
#if MKB_SWIFTPM
@import Mockingbird;
#else
#import <Mockingbird/Mockingbird-Swift.h>
#endif

@implementation MKBUnsignedCharInvocationHandler

- (instancetype)initWithNext:(MKBInvocationHandler *)next
{
  return (self = [super initWithObjCType:@encode(unsigned char)
                                    next:next
                                selector:@selector(unsignedCharValue)]);
}

- (MKBArgumentMatcher *)serializeArgumentAtIndex:(NSUInteger)index
                                   forInvocation:(NSInvocation *)invocation
{
  unsigned char value;
  [invocation getArgument:&value atIndex:index];
  return [[MKBArgumentMatcher alloc] init:@(value)
                              description:[NSString stringWithFormat:@"'%c'", value]
                               comparator:MKBEquatableComparator];
}

- (void)deserializeReturnValue:(id)returnValue forInvocation:(NSInvocation *)invocation
{
  unsigned char value = [returnValue unsignedCharValue];
  [invocation setReturnValue:&value];
}

@end

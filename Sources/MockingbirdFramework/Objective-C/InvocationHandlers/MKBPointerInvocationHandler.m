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
  return (self = [super initWithObjCType:@encode(void *) next:next]);
}

- (MKBArgumentMatcher *)serializeArgumentAtIndex:(NSUInteger)index
                                   forInvocation:(NSInvocation *)invocation
{
  void *value;
  [invocation getArgument:&value atIndex:index];
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

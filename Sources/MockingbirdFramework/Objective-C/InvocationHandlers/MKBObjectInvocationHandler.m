//
//  MKBObjectInvocationHandler.m
//  MockingbirdFramework
//
//  Created by typealias on 7/19/21.
//

#import "MKBObjectInvocationHandler.h"
#import "MKBComparator.h"
#import <Mockingbird/MKBTypeFacade.h>
#import <Mockingbird/Mockingbird-Swift.h>

@implementation MKBObjectInvocationHandler

- (instancetype)initWithNext:(MKBInvocationHandler *)next
{
  return (self = [super initWithObjCType:@encode(id) next:next]);
}

- (MKBArgumentMatcher *)serializeArgumentAtIndex:(NSUInteger)index
                                   forInvocation:(NSInvocation *)invocation
{
  __unsafe_unretained id value = nil;
  [invocation getArgument:&value atIndex:index];
  
  // Unwrapped boxed types within type facades.
  if ([value isKindOfClass:[MKBTypeFacade class]]) {
    value = ((MKBTypeFacade *)value).boxedObject;
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
  [invocation setReturnValue:&returnValue];
}

@end

#import "MKBStructInvocationHandler.h"
#import "MKBComparator.h"
#if MKB_SWIFTPM
@import Mockingbird;
#else
#import <Mockingbird/Mockingbird-Swift.h>
#endif

@implementation MKBStructInvocationHandler

- (instancetype)initWithNext:(MKBInvocationHandler *)next
{
  return (self = [super initWithObjCType:@encode(struct {})
                                    next:next
                                selector:@selector(getValue:)]);
}

- (MKBArgumentMatcher *)serializeArgumentAtIndex:(NSUInteger)index
                                   forInvocation:(NSInvocation *)invocation
{
  const char *argumentType = [invocation.methodSignature getArgumentTypeAtIndex:index];
  NSUInteger structSize = 0;
  NSGetSizeAndAlignment(argumentType, &structSize, NULL);
  void *buffer = calloc(1, structSize);
  [invocation getArgument:&buffer atIndex:index];
  NSData *value = [NSData dataWithBytes:buffer length:structSize];
  free(buffer);
  return [[MKBArgumentMatcher alloc] init:value
                              description:[NSString stringWithUTF8String:argumentType]
                               comparator:MKBEquatableComparator];
}

- (void)deserializeReturnValue:(id)returnValue forInvocation:(NSInvocation *)invocation
{
  const NSUInteger structSize = invocation.methodSignature.methodReturnLength;
  NSMutableData *value = [NSMutableData dataWithLength:structSize];
  [returnValue getValue:value.mutableBytes];
  [invocation setReturnValue:&value];
}

@end

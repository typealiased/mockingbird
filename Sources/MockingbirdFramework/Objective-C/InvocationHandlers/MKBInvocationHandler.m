#import "MKBInvocationHandler.h"

@implementation MKBInvocationHandler

- (instancetype)initWithNext:(MKBInvocationHandler *_Nullable)next
{
  // Superclass should override this implementation.
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (instancetype)initWithObjCType:(const char *)objCType
                            next:(MKBInvocationHandler *_Nullable)next
                        selector:(SEL)selector
{
  self = [super init];
  if (self) {
    _next = next;
    _objCType = objCType;
    _deserializationSelector = selector;
  }
  return self;
}

- (BOOL)canSerializeArgumentAtIndex:(NSUInteger)index forInvocation:(NSInvocation *)invocation
{
  const char *argumentType = [invocation.methodSignature getArgumentTypeAtIndex:index];
  return argumentType[0] == self.objCType[0];
}

- (BOOL)canDeserializeReturnValue:(id)returnValue forInvocation:(NSInvocation *)invocation
{
  const char *returnType = invocation.methodSignature.methodReturnType;
  return returnType[0] == self.objCType[0] &&
    [returnValue respondsToSelector:self.deserializationSelector];
}

- (MKBArgumentMatcher *)serializeArgumentAtIndex:(NSUInteger)index
                                   forInvocation:(NSInvocation *)invocation
{
  // Subclasses should override this implementation.
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (void)deserializeReturnValue:(id)returnValue forInvocation:(NSInvocation *)invocation
{
  // Subclasses should override this implementation.
  [self doesNotRecognizeSelector:_cmd];
}

@end

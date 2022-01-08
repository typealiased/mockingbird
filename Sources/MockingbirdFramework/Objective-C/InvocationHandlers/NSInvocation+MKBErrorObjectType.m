#import "NSInvocation+MKBErrorObjectType.h"

@implementation NSInvocation (MKBErrorObjectType)

- (BOOL)isErrorArgumentTypeAtIndex:(NSUInteger)index
{
  const char *argumentType = [self.methodSignature getArgumentTypeAtIndex:index];
  if (argumentType[0] != @encode(void *)[0]) {
    return NO;
  }
  
  const BOOL isLastArgument = (index == self.methodSignature.numberOfArguments-1);
  const BOOL isVoidReturnType = (self.methodSignature.methodReturnType[0] == @encode(void)[0]);
  if (!isLastArgument || isVoidReturnType) {
    return NO;
  }
  
  const size_t normalizedIndex = index-2; // self, _cmd
  const NSArray<NSString *> *components =
    [NSStringFromSelector(self.selector) componentsSeparatedByString:@":"];
  if (normalizedIndex >= components.count) {
    return NO;
  }
  
  const NSString *parameterName = components[normalizedIndex];
  if (![parameterName.lowercaseString containsString:@"error"]) { // Heuristic
    return NO;
  }
  
  return YES;
}

@end

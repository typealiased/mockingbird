#import "MKBComparator.h"
#import "MKBInvocationHandlerChain.h"
#import "MKBInvocationHandler.h"

#import "MKBBoolInvocationHandler.h"
#import "MKBCharInvocationHandler.h"
#import "MKBClassInvocationHandler.h"
#import "MKBCStringInvocationHandler.h"
#import "MKBDoubleInvocationHandler.h"
#import "MKBFloatInvocationHandler.h"
#import "MKBIntInvocationHandler.h"
#import "MKBLongInvocationHandler.h"
#import "MKBLongLongInvocationHandler.h"
#import "MKBObjectInvocationHandler.h"
#import "MKBPointerInvocationHandler.h"
#import "MKBSelectorInvocationHandler.h"
#import "MKBShortInvocationHandler.h"
#import "MKBStructInvocationHandler.h"
#import "MKBUnsignedCharInvocationHandler.h"
#import "MKBUnsignedIntInvocationHandler.h"
#import "MKBUnsignedLongInvocationHandler.h"
#import "MKBUnsignedLongLongInvocationHandler.h"
#import "MKBUnsignedShortInvocationHandler.h"

#if MKB_SWIFTPM
@import Mockingbird;
#else
#import <Mockingbird/Mockingbird-Swift.h>
#endif

@interface MKBInvocationHandlerChain ()

@property (nonatomic, strong, readwrite) MKBInvocationHandler *firstHandler;

@end

@implementation MKBInvocationHandlerChain

- (instancetype)init
{
  self = [super self];
  if (self) {
    // Initialized below in _reverse_ order. Always check lower precision types first.
    MKBInvocationHandler *structHandler = [[MKBStructInvocationHandler alloc] initWithNext:nil];
    MKBInvocationHandler *doubleHandler = [[MKBDoubleInvocationHandler alloc] initWithNext:structHandler];
    MKBInvocationHandler *floatHandler = [[MKBFloatInvocationHandler alloc] initWithNext:doubleHandler];
    MKBInvocationHandler *unsignedLongLongHandler = [[MKBUnsignedLongLongInvocationHandler alloc] initWithNext:floatHandler];
    MKBInvocationHandler *unsignedLongHandler = [[MKBUnsignedLongInvocationHandler alloc] initWithNext:unsignedLongLongHandler];
    MKBInvocationHandler *unsignedIntHandler = [[MKBUnsignedIntInvocationHandler alloc] initWithNext:unsignedLongHandler];
    MKBInvocationHandler *unsignedShortHandler = [[MKBUnsignedShortInvocationHandler alloc] initWithNext:unsignedIntHandler];
    MKBInvocationHandler *unsignedCharHandler = [[MKBUnsignedCharInvocationHandler alloc] initWithNext:unsignedShortHandler];
    MKBInvocationHandler *longLongHandler = [[MKBLongLongInvocationHandler alloc] initWithNext:unsignedCharHandler];
    MKBInvocationHandler *longHandler = [[MKBLongInvocationHandler alloc] initWithNext:longLongHandler];
    MKBInvocationHandler *intHandler = [[MKBIntInvocationHandler alloc] initWithNext:longHandler];
    MKBInvocationHandler *shortHandler = [[MKBShortInvocationHandler alloc] initWithNext:intHandler];
    MKBInvocationHandler *charHandler = [[MKBCharInvocationHandler alloc] initWithNext:shortHandler];
    MKBInvocationHandler *boolHandler = [[MKBBoolInvocationHandler alloc] initWithNext:charHandler];
    MKBInvocationHandler *cstringHandler = [[MKBCStringInvocationHandler alloc] initWithNext:boolHandler];
    MKBInvocationHandler *selectorHandler = [[MKBSelectorInvocationHandler alloc] initWithNext:cstringHandler];
    MKBInvocationHandler *pointerHandler = [[MKBPointerInvocationHandler alloc] initWithNext:selectorHandler];
    MKBInvocationHandler *classHandler = [[MKBClassInvocationHandler alloc] initWithNext:pointerHandler];
    MKBInvocationHandler *objectHandler = [[MKBObjectInvocationHandler alloc] initWithNext:classHandler];
    _firstHandler = objectHandler;
  }
  return self;
}

- (MKBArgumentMatcher *)serializeArgumentAtIndex:(NSUInteger)index
                                   forInvocation:(NSInvocation *)invocation {
  // Handle argument matchers applied to primitive parameter types.
  const NSUInteger argumentsCount = invocation.methodSignature.numberOfArguments;
  id _Nullable facadeValue =
    [[MKBInvocationRecorder sharedRecorder] getFacadeValueAt:index-2
                                              argumentsCount:argumentsCount-2];
  if ([facadeValue isKindOfClass:[MKBArgumentMatcher class]]) {
    return (MKBArgumentMatcher *)facadeValue;
  }
  
  MKBInvocationHandler *handler = self.firstHandler;
  while (handler) {
    if (![handler canSerializeArgumentAtIndex:index forInvocation:invocation]) {
      handler = handler.next;
      continue;
    }
    return [handler serializeArgumentAtIndex:index forInvocation:invocation];
  }
  
  // Default matcher for types that could not be handled.
  const char *argumentType = [invocation.methodSignature getArgumentTypeAtIndex:index];
  NSString *description = [NSString stringWithFormat:@"any() (unhandled '%s' Obj-C type)", argumentType];
  return [[MKBArgumentMatcher alloc] init:nil
                              description:description
                               comparator:MKBAnyComparator];
}

- (void)deserializeReturnValue:(id)returnValue forInvocation:(NSInvocation *)invocation {
  MKBInvocationHandler *handler = self.firstHandler;
  while (handler) {
    if (![handler canDeserializeReturnValue:returnValue forInvocation:invocation]) {
      handler = handler.next;
      continue;
    }
    [handler deserializeReturnValue:returnValue forInvocation:invocation];
    break;
  }
}

@end

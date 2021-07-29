//
//  MKBConcreteMock.m
//  MockingbirdFramework
//
//  Created by typealias on 7/17/21.
//

#import "MKBConcreteMock.h"
#import "MKBProperty.h"
#import "InvocationHandlers/MKBInvocationHandlerChain.h"
#import "InvocationHandlers/NSInvocation+MKBErrorObjectType.h"
#import <Mockingbird/Mockingbird-Swift.h>

@interface MKBConcreteMock ()
@property (nonatomic, strong, readwrite) MKBInvocationHandlerChain *invocationHandlerChain;
@end

@implementation MKBConcreteMock

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wobjc-designated-initializers"
- (instancetype)init
{
  if (self) {
    _mockingbirdContext = [[MKBContext alloc] init];
    _invocationHandlerChain = [[MKBInvocationHandlerChain alloc] init];
  }
  return self;
}
#pragma GCC diagnostic pop

- (NSArray<MKBProperty *> *)getProperties
{
  // Subclasses should override this implementation.
  return [[NSArray alloc] init];
}

#pragma mark - NSProxy

- (void)forwardInvocation:(NSInvocation *)invocation
{
  // Ensure that the argument and return value lifetimes are long enough.
  [invocation retainArguments];

  NSString *selectorName = NSStringFromSelector(invocation.selector);
  NSMutableArray<MKBArgumentMatcher *> *arguments = [[NSMutableArray alloc] init];
  const NSUInteger argumentCount = invocation.methodSignature.numberOfArguments;
  const BOOL isVoidReturnType =
    (invocation.methodSignature.methodReturnType[0] == @encode(void)[0]);
  
  // Account for self, _cmd arguments.
  for (NSUInteger i = 2; i < argumentCount; i++) {
    [arguments addObject:
     [self.invocationHandlerChain serializeArgumentAtIndex:i forInvocation:invocation]];
  }
  
  MKBSelectorType selectorType = MKBSelectorTypeMethod;
  NSString *setterSelectorName = nil;
  for (MKBProperty *property in [self getProperties]) {
    if (property.getter == invocation.selector) {
      selectorType = MKBSelectorTypeGetter;
    } else if (property.setter == invocation.selector) {
      selectorType = MKBSelectorTypeSetter;
      setterSelectorName = NSStringFromSelector(property.setter);
    }
  }
  
  MKBObjCInvocation *objcInvocation =
    [[MKBObjCInvocation alloc] initWithSelectorName:selectorName
                                 setterSelectorName:setterSelectorName
                                       selectorType:selectorType
                                          arguments:arguments];
  MKBInvocationRecorder *recorder = [MKBInvocationRecorder sharedRecorder];
  
  switch (recorder.mode) {
    case MKBInvocationRecorderModeNone: {
      id _Nullable returnValue =
        [self.mockingbirdContext.mocking
         objcDidInvoke:objcInvocation evaluating:^id _Nullable(MKBObjCInvocation *invocation) {
          return [self.mockingbirdContext.stubbing returnValueFor:invocation];
        }];

      if (!isVoidReturnType) {
        if (returnValue == [MKBStubbingContext noImplementation]) {
          if ([[self class] instancesRespondToSelector:invocation.selector]) {
            break; // Forward the invocation to ourself to handle.
          }
          // Mocks are strict by default, so fail the test now.
          [self.mockingbirdContext.stubbing failTestFor:objcInvocation];
        } else if ([returnValue isKindOfClass:[MKBErrorBox class]] &&
                   [invocation isErrorArgumentTypeAtIndex:argumentCount-1]) {
          __unsafe_unretained NSError *boxedError = [returnValue performSelector:@selector(error)];
          __unsafe_unretained NSError **errorOut;
          [invocation getArgument:&errorOut atIndex:argumentCount-1];
          *errorOut = boxedError;
        } else if (returnValue) {
          [self.invocationHandlerChain deserializeReturnValue:returnValue forInvocation:invocation];
        }
      }
      break;
    }

    case MKBInvocationRecorderModeStubbing:
    case MKBInvocationRecorderModeVerifying:{
      [recorder recordInvocation:objcInvocation context:self.mockingbirdContext];
      break;
    }
  }
}

@end

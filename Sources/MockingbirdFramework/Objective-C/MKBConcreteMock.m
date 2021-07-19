//
//  MKBConcreteMock.m
//  MockingbirdFramework
//
//  Created by typealias on 7/17/21.
//

#import "MKBConcreteMock.h"
#import "NSInvocation+MKBArgumentMatcher.h"
#import <Mockingbird/Mockingbird-Swift.h>

@implementation MKBConcreteMock

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wobjc-designated-initializers"
- (instancetype)init
{
  if (self) {
    _mockingContext = [[MKBMockingContext alloc] init];
    _stubbingContext = [[MKBStubbingContext alloc] init];
  }
  return self;
}
#pragma GCC diagnostic pop

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
    [arguments addObject:[invocation mkb_createArgumentMatcherAtIndex:i]];
  }
  
  MKBObjCInvocation *objcInvocation =
    [[MKBObjCInvocation alloc] initWithSelectorName:selectorName arguments:arguments];
  MKBInvocationRecorder *recorder = [MKBInvocationRecorder sharedRecorder];
  
  switch (recorder.mode) {
    case MKBInvocationRecorderModeNone: {
      id _Nullable returnValue =
        [self.mockingContext didInvoke:objcInvocation evaluating:^id _Nullable {
          return [self.stubbingContext returnValueFor:objcInvocation];
        }];

      if (!isVoidReturnType) {
        if ((NSObject *)returnValue == [MKBStubbingContext noImplementation]) {
          if ([[self class] instancesRespondToSelector:invocation.selector]) {
            break; // Forward the invocation to ourself to handle.
          }
          // Mocks are strict by default, so fail the test now.
          [self.stubbingContext failTestFor:objcInvocation];
        } else {
          [invocation setReturnValue:&returnValue];
        }
      }
      break;
    }

    case MKBInvocationRecorderModeStubbing:
    case MKBInvocationRecorderModeVerifying:{
      [recorder recordWithInvocation:objcInvocation
                      mockingContext:self.mockingContext
                     stubbingContext:self.stubbingContext];
      [NSThread exit];
      break;
    }
  }
}

@end

#import "../include/MKBTestUtils.h"

void MKBStopTest(NSString *reason)
{
  MKBThrowException([NSException exceptionWithName:@"co.bird.mockingbird.TestFailure"
                                            reason:reason
                                          userInfo:nil]);
}

void MKBThrowException(NSException *exception)
{
  @throw exception;
}

NSException *_Nullable MKBTryBlock(void(^_Nonnull NS_NOESCAPE block)(void))
{
  @try {
    block();
  }
  @catch (NSException *exception) {
    return exception;
  }
  return nil;
}

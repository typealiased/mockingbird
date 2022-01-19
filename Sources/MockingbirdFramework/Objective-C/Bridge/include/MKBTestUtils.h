#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

void MKBStopTest(NSString *reason);

void MKBThrowException(NSException *reason);

NSException *_Nullable MKBTryBlock(void(^_Nonnull NS_NOESCAPE block)(void));

NS_ASSUME_NONNULL_END

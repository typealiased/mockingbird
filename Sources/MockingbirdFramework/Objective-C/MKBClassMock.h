#import "MKBConcreteMock.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MKBProtocolMock;

@interface MKBClassMock : MKBConcreteMock

@property (nonatomic, strong, readonly) Class mockedClass;
@property (nonatomic, strong, readonly) MKBClassMock *_Nullable superclassMock;
@property (nonatomic, strong, readonly) NSArray<MKBProtocolMock *> *protocolMocks;

- (instancetype)initWithClass:(Class)aClass NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MKBContext;
@class MKBProperty;

@interface MKBConcreteMock : NSProxy

@property (nonatomic, strong, readonly) MKBContext *mockingbirdContext;

- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (NSArray<MKBProperty *> *)getProperties;

@end

NS_ASSUME_NONNULL_END

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKBProperty : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) SEL getter;
@property (nonatomic, readonly, nullable) SEL setter;

- (instancetype)initWithProperty:(objc_property_t)property NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

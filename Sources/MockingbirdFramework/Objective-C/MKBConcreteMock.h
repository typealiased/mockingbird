//
//  MKBConcreteMock.h
//  MockingbirdFramework
//
//  Created by typealias on 7/17/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MKBContext;

@interface MKBConcreteMock : NSProxy

@property (nonatomic, strong, readonly) MKBContext *mockingbirdContext;

- (instancetype)init NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END

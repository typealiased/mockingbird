//
//  MKBConcreteMock.h
//  MockingbirdFramework
//
//  Created by typealias on 7/17/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MKBMockingContext;
@class MKBStubbingContext;

@interface MKBConcreteMock : NSProxy

@property (nonatomic, strong, readonly) MKBMockingContext *mockingContext;
@property (nonatomic, strong, readonly) MKBStubbingContext *stubbingContext;

- (instancetype)init NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END

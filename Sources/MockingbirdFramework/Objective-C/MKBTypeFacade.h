//
//  MKBTypeFacade.h
//  MockingbirdFramework
//
//  Created by typealias on 7/17/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MKBConcreteMock;

@interface MKBTypeFacade<T> : NSProxy

@property (nonatomic, strong, readonly) id boxedObject;
@property (nonatomic, strong, readonly) MKBConcreteMock *mock;

- (instancetype)initWithMock:(id)mock object:(id)object NS_DESIGNATED_INITIALIZER;
- (T)fixupType;

/// Used from Swift to coerce a test double into an arbitrary type.
/// @param object A test double object.
+ (T)createFromObject:(id)object;

@end

NS_ASSUME_NONNULL_END

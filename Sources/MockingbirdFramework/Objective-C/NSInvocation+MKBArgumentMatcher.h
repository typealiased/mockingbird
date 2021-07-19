//
//  NSInvocation+MKBArgumentMatcher.h
//  MockingbirdFramework
//
//  Created by typealias on 7/17/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MKBArgumentMatcher;

@interface NSInvocation (MKBArgumentMatcher)

- (MKBArgumentMatcher *)mkb_createArgumentMatcherAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END

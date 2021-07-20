//
//  MKBComparator.h
//  MockingbirdFramework
//
//  Created by typealias on 7/19/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef BOOL (^MKBComparator)(id _Nullable lhs, id _Nullable rhs);

extern const MKBComparator MKBEquatableComparator;
extern const MKBComparator MKBAnyComparator;

NS_ASSUME_NONNULL_END

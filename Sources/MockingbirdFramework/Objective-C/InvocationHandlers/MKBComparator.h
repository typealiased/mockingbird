#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef BOOL (^MKBComparator)(id _Nullable lhs, id _Nullable rhs);

extern const MKBComparator MKBEquatableComparator;
extern const MKBComparator MKBAnyComparator;

NS_ASSUME_NONNULL_END

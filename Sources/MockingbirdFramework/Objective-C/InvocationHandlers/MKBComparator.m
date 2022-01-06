#import "MKBComparator.h"

const MKBComparator MKBEquatableComparator = ^BOOL(id _Nullable lhs, id _Nullable rhs) {
  if (![lhs respondsToSelector:@selector(isEqual:)]) {
    return lhs == rhs; // Fall back to pointer equality.
  }
  return [lhs isEqual:rhs];
};

const MKBComparator MKBAnyComparator = ^BOOL(id _Nullable lhs, id _Nullable rhs) {
  return YES;
};

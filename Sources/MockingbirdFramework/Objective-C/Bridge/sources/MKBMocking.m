#import "../include/MKBMocking.h"
#import <objc/runtime.h>

id MKBMock(id aType)
{
  if ([NSStringFromClass([aType class]) isEqualToString:@"Protocol"]) {
    return MKBMockProtocol(aType);
  } else {
    return MKBMockClass((Class)aType);
  }
}

// Swift Package Manager does not support mixed language targets, but Mockingbird has a
// bidirectional interop between Swift and Obj-C. This allows us to break the cyclic dependency
// caused by factoring out Swift and Obj-C into separate targets.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
id MKBMockClass(Class aClass) {
  const SEL sel = NSSelectorFromString(@"initWithClass:");
  return [[NSClassFromString(@"MKBClassMock") alloc] performSelector:sel withObject:aClass];
}

id MKBMockProtocol(id aProtocol) {
  const SEL sel = NSSelectorFromString(@"initWithProtocol:");
  return [[NSClassFromString(@"MKBProtocolMock") alloc] performSelector:sel withObject:aProtocol];
}
#pragma clang diagnostic pop

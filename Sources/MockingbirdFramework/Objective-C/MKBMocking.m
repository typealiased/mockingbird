//
//  MKBMocking.m
//  MockingbirdFramework
//
//  Created by typealias on 7/17/21.
//

#import "MKBMocking.h"
#import "MKBClassMock.h"
#import "MKBProtocolMock.h"
#import <objc/runtime.h>

id MKBMock(id aType)
{
  if ([NSStringFromClass([aType class]) isEqualToString:@"Protocol"]) {
    return MKBMockProtocol(aType);
  } else {
    return MKBMockClass((Class)aType);
  }
}

id MKBMockClass(Class aClass) {
  return [[MKBClassMock alloc] initWithClass:aClass];
}

id MKBMockProtocol(id aProtocol) {
  return [[MKBProtocolMock alloc] initWithProtocol:aProtocol];
}

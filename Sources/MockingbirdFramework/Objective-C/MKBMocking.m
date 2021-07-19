//
//  MKBMocking.m
//  MockingbirdFramework
//
//  Created by typealias on 7/17/21.
//

#import "MKBMocking.h"
#import "MKBClassMock.h"
#import "MKBProtocolMock.h"

id mkb_mockClass(Class aClass) {
  return [[MKBClassMock alloc] initWithClass:aClass];
}

id mkb_mockProtocol(id aProtocol) {
  return [[MKBProtocolMock alloc] initWithProtocol:aProtocol];
}

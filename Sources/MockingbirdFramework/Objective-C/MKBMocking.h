//
//  MKBMocking.h
//  MockingbirdFramework
//
//  Created by typealias on 7/17/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

id mkb_mock(id aType);

id mkb_mockClass(Class aClass);
id mkb_mockProtocol(id aProtocol);

void mkb_fail_test(NSString *reason);

NS_ASSUME_NONNULL_END

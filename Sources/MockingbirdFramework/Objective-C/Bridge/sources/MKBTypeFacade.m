//
//  MKBTypeFacade.m
//  MockingbirdFramework
//
//  Created by typealias on 7/17/21.
//

#import "../include/MKBTypeFacade.h"

@implementation MKBTypeFacade

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wobjc-designated-initializers"
- (instancetype)initWithMock:(id)mock object:(id)object
{
  if (self) {
    _mock = mock;
    _boxedObject = object;
  }
  return self;
}
#pragma GCC diagnostic pop

- (id)fixupType
{
  return self;
}

+ (id)createFromObject:(id)object
{
  return object;
}

#pragma mark - NSProxy

- (void)forwardInvocation:(NSInvocation *)invocation
{
  [invocation setTarget:self.mock];
}

@end

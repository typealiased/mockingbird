#import "../include/MKBTypeFacade.h"

@implementation MKBTypeFacade

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wobjc-designated-initializers"
- (instancetype)initWithMock:(id)mock object:(id)object
{
  if (self) {
    _mkb_mock = mock;
    _mkb_boxedObject = object;
    _mkb_isTypeFacade = YES;
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

- (bool)isTypeFacadeSelector:(SEL)aSelector {
  return aSelector == @selector(mkb_boxedObject)
      || aSelector == @selector(mkb_mock)
      || aSelector == @selector(mkb_isTypeFacade);
}

#pragma mark - NSProxy

- (void)forwardInvocation:(NSInvocation *)invocation
{
  if ([self isTypeFacadeSelector:invocation.selector]) {
    [invocation setTarget:self];
  } else {
    [invocation setTarget:self.mkb_mock];
  }
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
  return [(NSObject *)self.mkb_mock respondsToSelector:aSelector]
    || [self isTypeFacadeSelector:aSelector];
}

- (NSMethodSignature *_Nullable)methodSignatureForSelector:(SEL)aSelector
{
  return [(NSObject *)self.mkb_mock methodSignatureForSelector:aSelector];
}

@end

#import "MKBProtocolMock.h"
#import "MKBProperty.h"
#import <objc/runtime.h>

@implementation MKBProtocolMock

- (instancetype)initWithProtocol:(Protocol *)aProtocol
{
  if (!aProtocol) {
    return nil;
  }
  
  self = [super init];
  if (self) {
    _mockedProtocol = aProtocol;
  }
  return self;
}

- (NSString *)description
{
  const char *boxTypeName = class_getName(self.class);
  const char *mockedTypeName = protocol_getName(self.mockedProtocol);
  return [NSString stringWithFormat:@"%s<%s>", boxTypeName, mockedTypeName];
}

- (NSArray<MKBProperty *> *)getProperties
{
  uint count;
  objc_property_t *propertyList = protocol_copyPropertyList(self.mockedProtocol, &count);
  NSMutableArray<MKBProperty *> *properties = [[NSMutableArray alloc] initWithCapacity:count];
  for (size_t i = 0; i < count; i++) {
    [properties addObject:[[MKBProperty alloc] initWithProperty:propertyList[i]]];
  }
  free(propertyList);
  return properties;
}

#pragma mark - NSObject

// TODO: Does this work for inherited methods from other protocols?
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
  static const struct { BOOL isRequired; BOOL isInstance; } opts[4] = {
    {YES, YES}, {NO, YES}, {YES, NO}, {NO, NO}
  };
  for (size_t i = 0; i < 4; i++) {
    const struct objc_method_description methodDescription = protocol_getMethodDescription(self.mockedProtocol, aSelector, opts[i].isRequired, opts[i].isInstance);
    if (methodDescription.name != NULL) {
      return [NSMethodSignature signatureWithObjCTypes:methodDescription.types];
    }
  }
  return nil;
}

#pragma mark - NSObjectProtocol

- (BOOL)conformsToProtocol:(Protocol *)aProtocol
{
  return protocol_conformsToProtocol(self.mockedProtocol, aProtocol);
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
  return [self methodSignatureForSelector:aSelector] != nil
    || aSelector == @selector(mockingbirdContext);
}

@end

@implementation MKBProtocolMock(NSIsKindsImplementation)

- (BOOL)isNSValue__
{
  return NO;
}

- (BOOL)isNSTimeZone__
{
  return NO;
}

- (BOOL)isNSSet__
{
  return NO;
}

- (BOOL)isNSOrderedSet__
{
  return NO;
}

- (BOOL)isNSNumber__
{
  return NO;
}

- (BOOL)isNSDate__
{
  return NO;
}

- (BOOL)isNSString__
{
  return NO;
}

- (BOOL)isNSDictionary__
{
  return NO;
}

- (BOOL)isNSData__
{
  return NO;
}

- (BOOL)isNSArray__
{
  return NO;
}

@end

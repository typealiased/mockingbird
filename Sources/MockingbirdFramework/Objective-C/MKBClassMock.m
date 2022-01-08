#import "MKBClassMock.h"
#import "MKBProtocolMock.h"
#import "MKBProperty.h"
#import <objc/runtime.h>

@implementation MKBClassMock

- (instancetype)initWithClass:(Class)aClass
{
  if (aClass == Nil) {
    return nil;
  }
  
  self = [super init];
  if (self) {
    _mockedClass = aClass;
    
    // Handle class inheritance.
    const Class superclass = class_getSuperclass(aClass);
    if (superclass != Nil) {
      _superclassMock = [[MKBClassMock alloc] initWithClass:superclass];
    }
    
    // Handle multiple protocol conformance.
    NSMutableArray *protocolMocks = [[NSMutableArray alloc] init];
    unsigned int count;
    Protocol *__unsafe_unretained _Nonnull *_Nullable protocolList = class_copyProtocolList(aClass, &count);
    for (size_t i = 0; i < count; i++) {
      const MKBProtocolMock *protocolMock = [[MKBProtocolMock alloc] initWithProtocol:protocolList[i]];
      if (!protocolMock) {
        continue;
      }
      [protocolMocks addObject:protocolMock];
    }
    if (protocolList != NULL) {
      free(protocolList);
    }
    _protocolMocks = protocolMocks;
  }
  return self;
}

- (NSArray<MKBProperty *> *)getProperties
{
  uint count;
  objc_property_t *propertyList = class_copyPropertyList(self.mockedClass, &count);
  NSMutableArray<MKBProperty *> *properties = [[NSMutableArray alloc] initWithCapacity:count];
  for (size_t i = 0; i < count; i++) {
    [properties addObject:[[MKBProperty alloc] initWithProperty:propertyList[i]]];
  }
  free(propertyList);
  return properties;
}

#pragma mark - NSObject

- (NSString *)description
{
  const char *boxTypeName = class_getName(self.class);
  const char *mockedTypeName = class_getName(self.mockedClass);
  return [NSString stringWithFormat:@"%s<%s>", boxTypeName, mockedTypeName];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
  NSMethodSignature *signature = [self.mockedClass instanceMethodSignatureForSelector:aSelector];
  if (signature) {
    return signature;
  }
  
  // TODO: Handle dynamic properties here
  
  return [super methodSignatureForSelector:aSelector];
}

#pragma mark - NSObjectProtocol

- (BOOL)isKindOfClass:(Class)aClass
{
  return [self.mockedClass isSubclassOfClass:aClass];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol
{
  return class_conformsToProtocol(self.mockedClass, aProtocol)
    || [self.superclassMock conformsToProtocol:aProtocol];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
  return [self.mockedClass instancesRespondToSelector:aSelector]
    || aSelector == @selector(mockingbirdContext);
}

@end

@implementation MKBClassMock(NSIsKindsImplementation)

- (BOOL)isNSValue__
{
  return [self.mockedClass isSubclassOfClass:[NSValue class]];
}

- (BOOL)isNSTimeZone__
{
  return [self.mockedClass isSubclassOfClass:[NSTimeZone class]];
}

- (BOOL)isNSSet__
{
  return [self.mockedClass isSubclassOfClass:[NSSet class]];
}

- (BOOL)isNSOrderedSet__
{
  return [self.mockedClass isSubclassOfClass:[NSOrderedSet class]];
}

- (BOOL)isNSNumber__
{
  return [self.mockedClass isSubclassOfClass:[NSNumber class]];
}

- (BOOL)isNSDate__
{
  return [self.mockedClass isSubclassOfClass:[NSDate class]];
}

- (BOOL)isNSString__
{
  return [self.mockedClass isSubclassOfClass:[NSString class]];
}

- (BOOL)isNSDictionary__
{
  return [self.mockedClass isSubclassOfClass:[NSDictionary class]];
}

- (BOOL)isNSData__
{
  return [self.mockedClass isSubclassOfClass:[NSData class]];
}

- (BOOL)isNSArray__
{
  return [self.mockedClass isSubclassOfClass:[NSArray class]];
}

@end

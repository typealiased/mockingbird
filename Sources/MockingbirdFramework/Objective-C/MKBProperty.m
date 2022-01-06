#import "MKBProperty.h"

@implementation MKBProperty

- (instancetype)initWithProperty:(objc_property_t)property
{
  self = [super init];
  if (self) {
    _name = @(property_getName(property));
    
    BOOL isReadOnly = NO;
    
    NSArray *attributes = [@(property_getAttributes(property)) componentsSeparatedByString:@","];
    for (NSString *attribute in attributes) {
      unichar type = [attribute characterAtIndex:0];
      NSString *detail = [attribute substringFromIndex:1];
      switch (type) {
        case 'R':
          isReadOnly = YES;
          break;
        case 'G':
          _getter = NSSelectorFromString(detail);
          break;
        case 'S':
          _setter = NSSelectorFromString(detail);
          break;
        default:
          break;
      }
      
      if (_getter == NULL) {
        _getter = NSSelectorFromString(_name);
      }
      
      if (_setter == NULL && isReadOnly == NO) {
        NSString *name = [NSString stringWithFormat:@"set%@%@:",
                          [_name substringToIndex:1].uppercaseString,
                          [_name substringFromIndex:1]];
        _setter = NSSelectorFromString(name);
      }
    }
    
  }
  return self;
}

@end


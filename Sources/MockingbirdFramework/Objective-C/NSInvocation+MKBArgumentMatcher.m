//
//  NSInvocation+MKBArgumentMatcher.m
//  MockingbirdFramework
//
//  Created by typealias on 7/17/21.
//

#import "NSInvocation+MKBArgumentMatcher.h"
#import "MKBTypeFacade.h"
#import <Mockingbird/Mockingbird-Swift.h>

typedef BOOL (^Comparator)(id _Nullable lhs, id _Nullable rhs);

static const Comparator MKBEquatableComparator = ^BOOL(id _Nullable lhs, id _Nullable rhs) {
  if (![lhs respondsToSelector:@selector(isEqual:)]) {
    return lhs == rhs; // Fall back to pointer equality.
  }
  return [lhs isEqual:rhs];
};

static const Comparator MKBAnyComparator = ^BOOL(id _Nullable lhs, id _Nullable rhs) {
  return YES;
};

typedef struct {} MKBStructType;

@implementation NSInvocation (MKBArgumentMatcher)

- (MKBArgumentMatcher *)mkb_createArgumentMatcherAtIndex:(NSUInteger)index
{
  const char *argumentType = [self.methodSignature getArgumentTypeAtIndex:index];
  
  if (argumentType[0] == @encode(BOOL)[0]) {
    BOOL value;
    [self getArgument:&value atIndex:index];
    return [[MKBArgumentMatcher alloc] init:@(value)
                                description:value ? @"YES" : @"NO"
                                 comparator:MKBEquatableComparator];
    
  } else if (argumentType[0] == @encode(char)[0]) {
    char value;
    [self getArgument:&value atIndex:index];
    return [[MKBArgumentMatcher alloc] init:@(value)
                                description:[NSString stringWithFormat:@"'%c'", value]
                                 comparator:MKBEquatableComparator];
    
  } else if (argumentType[0] == @encode(char *)[0]) {
    char *value;
    [self getArgument:&value atIndex:index];
    NSString *description = [NSString stringWithUTF8String:value];
    return [[MKBArgumentMatcher alloc] init:description
                                description:description
                                 comparator:MKBEquatableComparator];
    
  } else if (argumentType[0] == @encode(Class)[0]) {
    __unsafe_unretained Class value = nil;
    [self getArgument:&value atIndex:index];
    return [[MKBArgumentMatcher alloc] init:value
                                description:NSStringFromClass(value)
                                 comparator:^BOOL(id _Nullable lhs, id _Nullable rhs) {
      if (![lhs respondsToSelector:@selector(isSubclassOfClass:)]) return false;
      return !![lhs performSelector:@selector(isSubclassOfClass:) withObject:rhs];
    }];
    
  } else if (argumentType[0] == @encode(double)[0]) {
    double value;
    [self getArgument:&value atIndex:index];
    return [[MKBArgumentMatcher alloc] init:@(value)
                                description:[NSString stringWithFormat:@"%lf", value]
                                 comparator:MKBEquatableComparator];
    
  } else if (argumentType[0] == @encode(float)[0]) {
    float value;
    [self getArgument:&value atIndex:index];
    return [[MKBArgumentMatcher alloc] init:@(value)
                                description:[NSString stringWithFormat:@"%f", value]
                                 comparator:MKBEquatableComparator];
    
  } else if (argumentType[0] == @encode(id)[0]) {
    __unsafe_unretained id value = nil;
    [self getArgument:&value atIndex:index];
    
    // Unwrapped boxed types within type facades.
    if ([NSStringFromClass([value class])
         isEqualToString:NSStringFromClass([MKBTypeFacade class])]) {
      value = ((MKBTypeFacade *)value).boxedObject;
    }
    
    // Use argument matchers directly.
    if ([NSStringFromClass([value class])
         isEqualToString:NSStringFromClass([MKBArgumentMatcher class])]) {
      return (MKBArgumentMatcher *)value;
    }
    
    NSString *_Nullable description = nil;
    if ([value respondsToSelector:@selector(description)]) description = [value description];
    return [[MKBArgumentMatcher alloc] init:value
                                description:description
                                 comparator:MKBEquatableComparator];
    
  } else if (argumentType[0] == @encode(int)[0]) {
    int value;
    [self getArgument:&value atIndex:index];
    return [[MKBArgumentMatcher alloc] init:@(value)
                                description:[NSString stringWithFormat:@"%d", value]
                                 comparator:MKBEquatableComparator];
    
  } else if (argumentType[0] == @encode(long)[0]) {
    long value;
    [self getArgument:&value atIndex:index];
    return [[MKBArgumentMatcher alloc] init:@(value)
                                description:[NSString stringWithFormat:@"%ld", value]
                                 comparator:MKBEquatableComparator];
    
  } else if (argumentType[0] == @encode(long long)[0]) {
    long long value;
    [self getArgument:&value atIndex:index];
    return [[MKBArgumentMatcher alloc] init:@(value)
                                description:[NSString stringWithFormat:@"%lld", value]
                                 comparator:MKBEquatableComparator];
    
  } else if (argumentType[0] == @encode(void *)[0]) {
    void *value;
    [self getArgument:&value atIndex:index];
    return [[MKBArgumentMatcher alloc] init:[NSValue valueWithPointer:value]
                                description:[NSString stringWithFormat:@"%p", value]
                                 comparator:MKBEquatableComparator];
    
  } else if (argumentType[0] == @encode(SEL)[0]) {
    SEL value;
    [self getArgument:&value atIndex:index];
    NSString *description = NSStringFromSelector(value);
    return [[MKBArgumentMatcher alloc] init:description
                                description:description
                                 comparator:MKBEquatableComparator];
    
  } else if (argumentType[0] == @encode(short)[0]) {
    short value;
    [self getArgument:&value atIndex:index];
    return [[MKBArgumentMatcher alloc] init:@(value)
                                description:[NSString stringWithFormat:@"%u", value]
                                 comparator:MKBEquatableComparator];
    
  } else if (argumentType[0] == @encode(MKBStructType)[0]) {
    NSUInteger structSize = 0;
    NSGetSizeAndAlignment(argumentType, &structSize, NULL);
    void *buffer = calloc(1, structSize);
    [self getArgument:&buffer atIndex:index];
    NSData *value = [NSData dataWithBytes:buffer length:structSize];
    free(buffer);
    return [[MKBArgumentMatcher alloc] init:value
                                description:[NSString stringWithUTF8String:argumentType]
                                 comparator:MKBEquatableComparator];
    
  } else if (argumentType[0] == @encode(unsigned char)[0]) {
    unsigned char value;
    [self getArgument:&value atIndex:index];
    return [[MKBArgumentMatcher alloc] init:@(value)
                                description:[NSString stringWithFormat:@"'%c'", value]
                                 comparator:MKBEquatableComparator];
    
  } else if (argumentType[0] == @encode(unsigned int)[0]) {
    unsigned int value;
    [self getArgument:&value atIndex:index];
    return [[MKBArgumentMatcher alloc] init:@(value)
                                description:[NSString stringWithFormat:@"%d", value]
                                 comparator:MKBEquatableComparator];
    
  } else if (argumentType[0] == @encode(unsigned long)[0]) {
    unsigned long value;
    [self getArgument:&value atIndex:index];
    return [[MKBArgumentMatcher alloc] init:@(value)
                                description:[NSString stringWithFormat:@"%ld", value]
                                 comparator:MKBEquatableComparator];
    
  } else if (argumentType[0] == @encode(unsigned long long)[0]) {
    unsigned long long value;
    [self getArgument:&value atIndex:index];
    return [[MKBArgumentMatcher alloc] init:@(value)
                                description:[NSString stringWithFormat:@"%lld", value]
                                 comparator:MKBEquatableComparator];
    
  } else if (argumentType[0] == @encode(unsigned short)[0]) {
    unsigned short value;
    [self getArgument:&value atIndex:index];
    return [[MKBArgumentMatcher alloc] init:@(value)
                                description:[NSString stringWithFormat:@"%hu", value]
                                 comparator:MKBEquatableComparator];
    
  }
  
  // TODO: Log warning
  return [[MKBArgumentMatcher alloc] init:nil
                              description:@"any() (unhandled Obj-C type)"
                               comparator:MKBAnyComparator];
}

@end

#import "../include/MKBTestExpectation.h"

@implementation MKBTestExpectation

+ (instancetype)createFromExpectation:(XCTestExpectation *)expectation
{
  return (MKBTestExpectation *)expectation;
}

@end

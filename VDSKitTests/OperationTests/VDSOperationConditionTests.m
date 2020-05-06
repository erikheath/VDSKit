//
//  VDSOperationConditionTests.m
//  VDSKitTests
//
//  Created by Erikheath Thomas on 5/5/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "../VDSKit/VDSKit.h"

@interface VDSOperationConditionTests : XCTestCase

@end

@implementation VDSOperationConditionTests

- (void)testBasicInit {
    VDSOperationCondition* condition = [[VDSOperationCondition alloc] init];
    XCTAssertNotNil(condition);
    XCTAssertEqualObjects(VDSOperationCondition.conditionName, @"Generic Condition");
    XCTAssertEqual(VDSOperationCondition.isMutuallyExclusive, NO);
    VDSOperation* operation = nil;
    XCTAssertThrowsSpecific([condition evaluateForOperation:operation error:nil], NSException);
    operation = [VDSOperation new];
    XCTAssertTrue([condition evaluateForOperation:operation error:nil]);
}


@end

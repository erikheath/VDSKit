//
//  VDSMutexConditionTests.m
//  VDSKitTests
//
//  Created by Erikheath Thomas on 5/2/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "../VDSKit/VDSKit.h"

@interface VDSMutexConditionTests : XCTestCase

@end

@implementation VDSMutexConditionTests

- (void)testBasicInit {
    VDSMutexCondition* condition = [VDSMutexCondition new];
    XCTAssertNotNil(condition);
    XCTAssertTrue(VDSMutexCondition.isMutuallyExclusive);
    NSString* conditionName = [NSString stringWithFormat:@"MutuallyExclusive<%@>", NSStringFromClass([VDSMutexCondition class])];
    XCTAssertEqualObjects(VDSMutexCondition.conditionName, conditionName);
}

- (void)testDependencyForOperation {
    VDSMutexCondition* condition = [VDSMutexCondition new];
    XCTAssertNotNil(condition);
    VDSOperation* operation1 = [VDSOperation new];
    XCTAssertNil([condition dependencyForOperation:operation1]);
    VDSOperation* operation2 = [VDSOperation new];
    XCTAssertNil([condition dependencyForOperation:operation2]);
    VDSOperation* operation3 = [VDSOperation new];
    XCTAssertNil([condition dependencyForOperation:operation3]);

    VDSOperationQueue* queue = [VDSOperationQueue new];
    [queue setSuspended:YES];
    
    [operation1 addCondition:condition];
    [operation2 addCondition:condition];
    [operation3 addCondition:condition];

    [queue addOperations:@[operation1, operation2, operation3]];

    XCTKVOExpectation* expectOp1 = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(isExecuting)) object:operation1 expectedValue:@(YES)];
    XCTKVOExpectation* expectOp2 = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(isExecuting)) object:operation2 expectedValue:@(YES)];
    XCTKVOExpectation* expectOp3 = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(isExecuting)) object:operation3 expectedValue:@(YES)];

    XCTKVOExpectation* expectOp1Fin = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(isFinished)) object:operation1 expectedValue:@(YES)];
    XCTKVOExpectation* expectOp2Fin = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(isFinished)) object:operation2 expectedValue:@(YES)];
    XCTKVOExpectation* expectOp3Fin = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(isFinished)) object:operation3 expectedValue:@(YES)];

    
    XCTWaiter* waiter = [[XCTWaiter alloc] initWithDelegate:self];
    [queue setSuspended:NO];
    [waiter waitForExpectations:@[expectOp1, expectOp1Fin, expectOp2, expectOp2Fin, expectOp3, expectOp3Fin] timeout:5 enforceOrder:NO];
    
}

@end


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

    XCTKVOExpectation* expectOp1 = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(state)) object:operation1 expectedValue:@(VDSOperationExecuting)];
    XCTKVOExpectation* expectOp2 = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(state)) object:operation2 expectedValue:@(VDSOperationExecuting)];
    XCTKVOExpectation* expectOp3 = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(state)) object:operation3 expectedValue:@(VDSOperationExecuting)];

    XCTKVOExpectation* expectOp1Fin = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(state)) object:operation1 expectedValue:@(VDSOperationFinished)];
    XCTKVOExpectation* expectOp2Fin = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(state)) object:operation2 expectedValue:@(VDSOperationFinished)];
    XCTKVOExpectation* expectOp3Fin = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(state)) object:operation3 expectedValue:@(VDSOperationFinished)];

    
    XCTWaiter* waiter = [[XCTWaiter alloc] initWithDelegate:self];
    [queue setSuspended:NO];
    [waiter waitForExpectations:@[expectOp1, expectOp1Fin, expectOp2, expectOp2Fin, expectOp3, expectOp3Fin] timeout:5 enforceOrder:YES];
    
}

@end


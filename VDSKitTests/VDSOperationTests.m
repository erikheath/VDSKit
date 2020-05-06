//
//  VDSOperationTests.m
//  VDSKitTests
//
//  Created by Erikheath Thomas on 5/2/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "../VDSKit/VDSKit.h"

@interface VDSOperationTests : XCTestCase

@end

@interface VDSOperation (TestableOperation)

- (BOOL)canTransitionToState:(VDSOperationState)state;

@end

@implementation VDSOperationTests



- (void)testBasicInit {
    VDSOperation* operation = [[VDSOperation alloc] init];
    XCTAssertNotNil(operation);
    XCTAssertNotNil(operation.observers);
    XCTAssertEqual(operation.observers.count, 0);
    XCTAssertNotNil(operation.errors);
    XCTAssertEqual(operation.errors.count, 0);
    XCTAssertFalse(operation.enqueued);
    XCTAssertNil(operation.delegate);
}


- (void)testAddCondition {
    VDSOperation* operation = [VDSOperation new];
    XCTAssertEqual(operation.conditions.count, 0);
    
    VDSOperationCondition* condition = [VDSOperationCondition new];
    [operation addCondition:condition];
    XCTAssertEqual(operation.conditions.count, 1);
    XCTAssertEqual(condition, operation.conditions[0]);
    
    condition = [VDSOperationCondition new];
    XCTAssertNotEqual(condition, operation.conditions[0]);
    
    [operation addCondition:condition];
    XCTAssertEqual(operation.conditions.count, 2);
    XCTAssertNotEqual(condition, operation.conditions[0]);
    XCTAssertEqual(condition, operation.conditions[1]);
    
    condition = nil;
    XCTAssertThrowsSpecificNamed([operation addCondition:condition], NSException, NSInternalInconsistencyException);
    
    id wrongType = [NSObject new];
    XCTAssertThrowsSpecificNamed([operation addCondition:wrongType], NSException, NSInternalInconsistencyException);
    
    operation = [VDSOperation new];
    condition = [VDSOperationCondition new];
    VDSOperationQueue* queue = [VDSOperationQueue new];
    [queue setSuspended:YES];
    
    XCTKVOExpectation* expect = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(enqueued)) object:operation expectedValue:@(YES)];
    XCTWaiter* waiter = [[XCTWaiter alloc] initWithDelegate:self];
    [queue addOperation:operation];
    [waiter waitForExpectations:@[expect] timeout:10];
    
    XCTAssertThrowsSpecificNamed([operation addCondition:condition], NSException, NSInternalInconsistencyException);
    
    
}

- (void)testAddObserver {
    VDSOperation* operation = [VDSOperation new];
    XCTAssertNotNil(operation.observers);
    XCTAssertEqual(operation.observers.count, 0);
    
    VDSBlockObserver* observer = [[VDSBlockObserver alloc] initWithStartOperationHandler:nil finishOperationHandler:nil];
    XCTAssertNotNil(observer);
    
    [operation addObserver:observer];
    XCTAssertEqual(operation.observers.count, 1);
    XCTAssertEqual(observer, operation.observers[0]);
    
    observer = [[VDSBlockObserver alloc] initWithStartOperationHandler:^(VDSOperation * _Nonnull startOperation) {
        return;
    } finishOperationHandler:^(VDSOperation * _Nonnull finishOperation) {
        return;
    }];
    
    [operation addObserver:observer];
    XCTAssertEqual(operation.observers.count, 2);
    XCTAssertNotEqual(observer, operation.observers[0]);
    XCTAssertEqual(observer, operation.observers[1]);
    
    VDSOperationQueue* queue = [VDSOperationQueue new];
    XCTAssertNotNil(queue);
    
    operation = [VDSOperation new];
    XCTAssertNotNil(operation);
    XCTAssertEqual(operation.observers.count, 0);
    
    [queue setSuspended:YES];
    XCTKVOExpectation* expectation = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(enqueued)) object:operation expectedValue:@(YES)];
    XCTWaiter* waiter = [[XCTWaiter alloc] initWithDelegate:self];
    [queue addOperation:operation];
    [waiter waitForExpectations:@[expectation] timeout:10];
    
    XCTAssertThrowsSpecificNamed([operation addObserver:observer], NSException, NSInternalInconsistencyException);
    
    expectation = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(isFinished)) object:operation expectedValue:@(YES)];
    waiter = [[XCTWaiter alloc] initWithDelegate:self];
    
    [queue setSuspended:NO];
    [waiter waitForExpectations:@[expectation] timeout:10];
    
    XCTAssertThrowsSpecificNamed([operation addObserver:observer], NSException, NSInternalInconsistencyException);
}

- (void)testAddCompletionBlock {
    VDSOperation* operation = [[VDSOperation alloc] init];
    XCTAssertNotNil(operation);
    XCTAssertNil(operation.completionBlock);
    
    NSNumber* __block blockOneFlag = @(NO);
    void(^block)(void) = ^{
        blockOneFlag = @(YES);
        return;
    };
    
    [operation addCompletionBlock:block];
    XCTAssertNotNil(operation.completionBlock);
    XCTAssertEqual(block, operation.completionBlock);
    
    NSNumber* __block blockTwoFlag = @(NO);
    void(^blockTwo)(void) = ^{
        blockTwoFlag = @(YES);
    };

    [operation addCompletionBlock:blockTwo];
    XCTAssertNotNil(operation.completionBlock);
    XCTAssertNotEqual(block, operation.completionBlock);
    
    operation.completionBlock();
    XCTAssertTrue(blockOneFlag);
    XCTAssertTrue(blockTwoFlag);
    
    void(^blockThree)(void);
    XCTAssertThrowsSpecificNamed([operation addCompletionBlock:blockThree], NSException, NSInternalInconsistencyException);
}

@end

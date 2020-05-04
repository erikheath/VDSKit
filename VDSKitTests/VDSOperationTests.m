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
    XCTAssertEqual(operation.state, VDSOperationInitialized);
    XCTAssertNotNil([operation valueForKey:@"stateCoordinator"]); // This is a private property that must not be nil.
    XCTAssertNotNil(operation.observers);
    XCTAssertEqual(operation.observers.count, 0);
    XCTAssertNotNil(operation.errors);
    XCTAssertEqual(operation.errors.count, 0);
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
    
    XCTKVOExpectation* expect = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(state)) object:operation expectedValue:@(VDSOperationReady)];
    [queue addOperation:operation];
    XCTWaiter* waiter = [[XCTWaiter alloc] initWithDelegate:self];
    [waiter waitForExpectations:@[expect] timeout:10];
    
    XCTAssertThrowsSpecificNamed([operation addCondition:condition], NSException, NSInternalInconsistencyException);
    
    
    expect = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(state)) object:operation expectedValue:@(VDSOperationFinished)];
    waiter = [[XCTWaiter alloc] initWithDelegate:self];
    [queue setSuspended:NO];
    [waiter waitForExpectations:@[expect] timeout:10];
    
    XCTAssertThrowsSpecificNamed([operation addCondition:condition], NSException, NSInternalInconsistencyException);
}

- (void)testAddObserver {
    VDSOperation* operation = [VDSOperation new];
    XCTAssertNotNil(operation.observers);
    XCTAssertEqual(operation.observers.count, 0);
    
    VDSBlockObserver* observer = [[VDSBlockObserver alloc] initWithStartOperationHandler:nil produceOperationHandler:nil finishOperationHandler:nil];
    XCTAssertNotNil(observer);
    
    [operation addObserver:observer];
    XCTAssertEqual(operation.observers.count, 1);
    XCTAssertEqual(observer, operation.observers[0]);
    
    observer = [[VDSBlockObserver alloc] initWithStartOperationHandler:^(VDSOperation * _Nonnull startOperation) {
        return;
    } produceOperationHandler:^(VDSOperation * _Nonnull originOperation, NSOperation * _Nonnull producedOperation) {
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
    XCTKVOExpectation* expectation = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(state)) object:operation expectedValue:@(VDSOperationReady)];
    XCTWaiter* waiter = [[XCTWaiter alloc] initWithDelegate:self];
    [queue addOperation:operation];
    [waiter waitForExpectations:@[expectation] timeout:10];
    
    XCTAssertThrowsSpecificNamed([operation addObserver:observer], NSException, NSInternalInconsistencyException);
    
    expectation = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(state)) object:operation expectedValue:@(VDSOperationFinished)];
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

- (void)testAddDependency {
    VDSOperation* operation = [VDSOperation new];
    XCTAssertNotNil(operation);
    XCTAssertEqual(operation.dependencies.count, 0);
    
    NSOperation* nilOp = nil;
    XCTAssertThrowsSpecificNamed([operation addDependency:nilOp], NSException, NSInternalInconsistencyException);
    
    id object = [NSObject new];
    XCTAssertThrowsSpecificNamed([operation addDependency:object], NSException, NSInternalInconsistencyException);
    
    NSOperation* depOp1 = [NSOperation new];
    [operation addDependency:depOp1];
    XCTAssertEqual(operation.dependencies.count, 1);
    XCTAssertEqual(operation.dependencies[0], depOp1);
    
    NSOperation* depOp2 = [NSOperation new];
    [operation addDependency:depOp2];
    XCTAssertEqual(operation.dependencies.count, 2);
    XCTAssertNotEqual(operation.dependencies[0], depOp2);
    XCTAssertEqual(operation.dependencies[1], depOp2);
    
    operation = [VDSOperation new];
    XCTAssertNotNil(operation);
    VDSOperationQueue* queue = [VDSOperationQueue new];
    XCTAssertNotNil(queue);
    [queue setSuspended:YES];
    
    [queue addOperation:operation];
    XCTAssertNoThrowSpecificNamed([operation addDependency:depOp1], NSException, NSInternalInconsistencyException);
    
    operation = [VDSOperation new];
    queue = [VDSOperationQueue new];
    [queue setSuspended:YES];
    [queue addOperation:operation];
    XCTKVOExpectation* expectation = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(state)) object:operation expectedValue:@(VDSOperationFinished)];
    XCTWaiter* waiter = [[XCTWaiter alloc] initWithDelegate:self];
    [queue setSuspended:NO];
    [waiter waitForExpectations:@[expectation] timeout:10];
    
    XCTAssertThrowsSpecificNamed([operation addDependency:depOp2], NSException, NSInternalInconsistencyException);

}

- (void)testAddDependencies {
    VDSOperation* operation = [VDSOperation new];
    XCTAssertNotNil(operation);
    XCTAssertEqual(operation.dependencies.count, 0);
    XCTAssertEqual(operation.state, VDSOperationInitialized);
    
    VDSOperation* op0 = [VDSOperation new];
    NSOperation* op1 = [NSOperation new];
    NSOperation* op2 = [NSOperation new];
    NSOperation* op3 = [NSOperation new];
    VDSOperation* op4 = [VDSOperation new];
    NSArray* opArray = @[op0, op1, op2, op3, op4];
    
    [operation addDependencies:opArray];
    XCTAssertEqual(operation.dependencies.count, 5);
    XCTAssertEqual(operation.dependencies[0], op0);
    XCTAssertEqual(operation.dependencies[1], op1);
    XCTAssertEqual(operation.dependencies[2], op2);
    XCTAssertEqual(operation.dependencies[3], op3);
    XCTAssertEqual(operation.dependencies[4], op4);

    VDSOperationQueue* queue = [VDSOperationQueue new];
    queue.maxConcurrentOperationCount = 1;
    XCTAssertNotNil(queue);
    [queue setSuspended:YES];
    
    [queue addOperations:opArray];
    [queue addOperation:operation];
    XCTAssertEqual(operation.state, VDSOperationPending);
    
    XCTKVOExpectation* expect0 = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(state)) object:op0 expectedValue:@(VDSOperationFinished)];
    XCTKVOExpectation* expect1 = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(isFinished)) object:op1 expectedValue:@(YES)];
    XCTKVOExpectation* expect2 = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(isFinished)) object:op2 expectedValue:@(YES)];
    XCTKVOExpectation* expect3 = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(isFinished)) object:op3 expectedValue:@(YES)];
    XCTKVOExpectation* expect4 = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(state)) object:op4 expectedValue:@(VDSOperationFinished)];
    XCTKVOExpectation* expect5 = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(state)) object:operation expectedValue:@(VDSOperationFinished)];
    
    XCTWaiter* waiter = [[XCTWaiter alloc] initWithDelegate:self];
    
    [queue setSuspended:NO];
    [waiter waitForExpectations:@[expect0, expect1, expect2, expect3, expect4, expect5] timeout:10];
    
}

// This is a private method for the VDSOperation class, but is important
// enough to test it in isolation (as well as in all other contexts).
- (void)testCanTransitionToState {
    VDSOperation* operation = [VDSOperation new];
    XCTAssertNotNil(operation);
    
    XCTAssertEqual(operation.state, VDSOperationInitialized);
    XCTAssertTrue([operation canTransitionToState:VDSOperationPending]);
    
    XCTAssertFalse([operation canTransitionToState:VDSOperationInitialized]);
    XCTAssertFalse([operation canTransitionToState:VDSOperationEvaluating]);
    XCTAssertFalse([operation canTransitionToState:VDSOperationReady]);
    XCTAssertFalse([operation canTransitionToState:VDSOperationExecuting]);
    XCTAssertFalse([operation canTransitionToState:VDSOperationFinishing]);
    XCTAssertFalse([operation canTransitionToState:VDSOperationFinished]);

    NSOperation* depOp1 = [NSOperation new];
    [operation addDependency:depOp1];
    VDSOperationQueue* queue = [VDSOperationQueue new];
    [queue setSuspended:YES];
    [queue addOperations:@[depOp1, operation]];
    
    XCTAssertEqual(operation.state, VDSOperationPending);
    XCTAssertTrue([operation canTransitionToState:VDSOperationEvaluating]);
    
    XCTAssertFalse([operation canTransitionToState:VDSOperationPending]);
    XCTAssertFalse([operation canTransitionToState:VDSOperationInitialized]);
    XCTAssertFalse([operation canTransitionToState:VDSOperationReady]);
    XCTAssertFalse([operation canTransitionToState:VDSOperationExecuting]);
    XCTAssertFalse([operation canTransitionToState:VDSOperationFinishing]);
    XCTAssertFalse([operation canTransitionToState:VDSOperationFinished]);

    queue = [VDSOperationQueue new];
    XCTAssertNotNil(queue);
    [queue setSuspended:YES];
    
    operation = [VDSOperation new];
    XCTAssertEqual(operation.state, VDSOperationInitialized);
    
    XCTKVOExpectation* expection1 = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(state)) object:operation expectedValue:@(VDSOperationEvaluating)];
    XCTKVOExpectation* expection2 = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(state)) object:operation expectedValue:@(VDSOperationReady)];
    XCTWaiter* waiter = [[XCTWaiter alloc] initWithDelegate:self];
    
    [queue addOperation:operation];
    [waiter waitForExpectations:@[expection1, expection2] timeout:10];
    
    XCTAssertEqual(operation.state, VDSOperationReady);
    XCTAssertTrue([operation canTransitionToState:VDSOperationExecuting]);
    XCTAssertTrue([operation canTransitionToState:VDSOperationFinishing]);
    
    XCTAssertFalse([operation canTransitionToState:VDSOperationInitialized]);
    XCTAssertFalse([operation canTransitionToState:VDSOperationPending]);
    XCTAssertFalse([operation canTransitionToState:VDSOperationEvaluating]);
    XCTAssertFalse([operation canTransitionToState:VDSOperationReady]);
    XCTAssertFalse([operation canTransitionToState:VDSOperationFinished]);

    expection1 = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(state))
                                                     object:operation
                                              expectedValue:@(VDSOperationExecuting)];
    expection2 = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(state))
                                                     object:operation
                                              expectedValue:@(VDSOperationFinishing)];
    XCTKVOExpectation* expection3 = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(state))
                                                                        object:operation
                                                                 expectedValue:@(VDSOperationFinished)];

    waiter = [[XCTWaiter alloc] initWithDelegate:self];
    [queue setSuspended:NO];
    [waiter waitForExpectations:@[expection1, expection2, expection3]
                        timeout:10
                   enforceOrder:YES];
    
    XCTAssertEqual(operation.state, VDSOperationFinished);
    
    XCTAssertFalse([operation canTransitionToState:VDSOperationInitialized]);
    XCTAssertFalse([operation canTransitionToState:VDSOperationPending]);
    XCTAssertFalse([operation canTransitionToState:VDSOperationEvaluating]);
    XCTAssertFalse([operation canTransitionToState:VDSOperationReady]);
    XCTAssertFalse([operation canTransitionToState:VDSOperationExecuting]);
    XCTAssertFalse([operation canTransitionToState:VDSOperationFinishing]);
    XCTAssertFalse([operation canTransitionToState:VDSOperationFinished]);

}

- (void)testProduceOperation {
    VDSOperation* operation = [VDSOperation new];
    XCTAssertNotNil(operation);
    
    BOOL __block produceFlag = NO;
    VDSOperation* __block originalOp = nil;
    NSOperation* __block newOp = nil;
    
    VDSBlockObserver* observer = [[VDSBlockObserver alloc] initWithStartOperationHandler:nil produceOperationHandler:^(VDSOperation * _Nonnull originOperation, NSOperation * _Nonnull producedOperation) {
        produceFlag = YES;
        originalOp = originOperation;
        newOp = producedOperation;
    } finishOperationHandler:nil];
    XCTAssertNotNil(observer);
    
    [operation addObserver:observer];
    
    NSOperation* producedOp = [NSOperation new];
    XCTAssertNotNil(producedOp);
    
    [operation produceOperation:producedOp];
    XCTAssertEqual(YES, produceFlag);
    XCTAssertEqual(originalOp, operation);
    XCTAssertEqual(newOp, producedOp);
    
}

// This is a configuration of a single operation running on
// on a queue without conditions, dependencies, observers, etc.
// This test confirms that, on a successful, the operation moves
// through a series of states in a known order.
// More complex configurations are in VDSOperationIntegrationTests.
//
// Note that because isReady calls evaluateConditons which changes the
// state of the operation to VDSOperationEvaluating, a change of
// state may be made before a KVO notification is sent to other
// observers, resulting in 'missing' the state change from
// VDSOperationInitialized to VDSOperationPending, where
// VDSOperationPending is the new value. To guarantee receipt
// of VDSOperationPending, subscribe using the NSKeyValueObservingOptionPrior
// option to receive a 'will change' notification that will have
// VDSOperationPending as the new value. See the below test for an example.
- (void)testSuccessfulRun1 {
    VDSOperation* operation = [VDSOperation new];
    XCTAssertNotNil(operation);
    XCTAssertEqual(operation.state, VDSOperationInitialized);

    VDSOperationQueue* queue = [VDSOperationQueue new];
    XCTAssertNotNil(queue);
    
    XCTKVOExpectation* initialized = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(state))
                                                                         object:operation
                                                                  expectedValue:@(VDSOperationInitialized)];
    XCTKVOExpectation* pending = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(state))
                                                                         object:operation
                                                                  expectedValue:@(VDSOperationPending)
                                                                    options:NSKeyValueObservingOptionPrior];
    XCTKVOExpectation* evaluating = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(state))
                                                                         object:operation
                                                                  expectedValue:@(VDSOperationEvaluating)];
    XCTKVOExpectation* ready = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(state))
                                                                         object:operation
                                                                  expectedValue:@(VDSOperationReady)];
    XCTKVOExpectation* executing = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(state))
                                                                         object:operation
                                                                  expectedValue:@(VDSOperationExecuting)];
    XCTKVOExpectation* finishing = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(state))
                                                                         object:operation
                                                                  expectedValue:@(VDSOperationFinishing)];
    XCTKVOExpectation* finished = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(state))
                                                                         object:operation
                                                                  expectedValue:@(VDSOperationFinished)];

    XCTWaiter* waiter = [[XCTWaiter alloc] initWithDelegate:self];
    
    [queue addOperation:operation];
    
    [waiter waitForExpectations:@[initialized, pending, evaluating, ready, executing, finishing, finished] timeout:10 enforceOrder:YES];
    XCTAssertEqual(operation.state, VDSOperationFinished);
}

// This is a configuration of a single operation running on
// a queue without conditions, dependencies, etc. The operation
// is canceled before being added to the queue. In a second
// version, an operation is placed onto a suspended queue
// and then canceled prior to the queue being unsuspended.
- (void)testCanceledRun {
    VDSOperation* operation = [VDSOperation new];
    XCTAssertNotNil(operation);
    
    VDSOperationQueue* queue = [VDSOperationQueue new];
    XCTAssertNotNil(queue);
    
    XCTKVOExpectation* initialized = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(state))
                                                                         object:operation
                                                                  expectedValue:@(VDSOperationInitialized)];
    XCTKVOExpectation* pending = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(state))
                                                                         object:operation
                                                                  expectedValue:@(VDSOperationPending)
                                                                    options:NSKeyValueObservingOptionPrior];
    XCTKVOExpectation* evaluating = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(state))
                                                                         object:operation
                                                                  expectedValue:@(VDSOperationEvaluating)];
    evaluating.inverted = YES;
    XCTKVOExpectation* ready = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(state))
                                                                         object:operation
                                                                  expectedValue:@(VDSOperationReady)];
    XCTKVOExpectation* executing = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(state))
                                                                         object:operation
                                                                  expectedValue:@(VDSOperationExecuting)];
    executing.inverted = YES;
    XCTKVOExpectation* finishing = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(state))
                                                                         object:operation
                                                                  expectedValue:@(VDSOperationFinishing)
                                                                      options:NSKeyValueObservingOptionPrior];
    XCTKVOExpectation* finished = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(state))
                                                                         object:operation
                                                                  expectedValue:@(VDSOperationFinished)
                                                                     options:NSKeyValueObservingOptionPrior];
    
    XCTWaiter* waiter = [[XCTWaiter alloc] initWithDelegate:self];

    NSError* error = [NSError errorWithDomain:VDSKitErrorDomain code:VDSOperationExecutionFailed userInfo:nil];
    [operation cancelWithError:error];
    XCTAssertTrue(operation.isCancelled);
    XCTAssertTrue(operation.errors.count == 1);
    XCTAssertEqual(operation.errors[0], error);

    [queue addOperation:operation];
    
    [waiter waitForExpectations:@[initialized, pending, finishing, finished] timeout:2.0 enforceOrder:YES];
    
    waiter = [[XCTWaiter alloc] initWithDelegate:self];
    [waiter waitForExpectations:@[evaluating, ready, executing] timeout:2.0];
    
    XCTAssertEqual(operation.state, VDSOperationFinished);
    XCTAssertEqual(operation.isFinished, YES);
    
}



@end

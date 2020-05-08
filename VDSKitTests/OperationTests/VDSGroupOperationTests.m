//
//  VDSGroupOperationTests.m
//  VDSKitTests
//
//  Created by Erikheath Thomas on 5/2/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "../../VDSKit/VDSKit.h"

@interface VDSGroupOperationTests : XCTestCase

@end

@implementation VDSGroupOperationTests

- (void)testBasicInit {
    VDSGroupOperation* group = [VDSGroupOperation new];
    XCTAssertNotNil(group);
    XCTAssertNotNil(group.internalQueue);
    XCTAssertTrue(group.internalQueue.suspended);
    XCTAssertEqual(group.internalQueue.delegate, group);
    XCTAssertEqual(group.internalQueue.operations.count, 1);
    
    NSOperation* operation1 = [NSOperation new];
    XCTAssertNotNil(operation1);
    NSBlockOperation* operation2 = [NSBlockOperation new];
    XCTAssertNotNil(operation2);
    [operation2 addExecutionBlock:^{
        return;
    }];
    VDSOperation* operation3 = [VDSOperation new];
    XCTAssertNotNil(operation3);
    VDSBlockOperation* operation4 = [[VDSBlockOperation alloc] initWithMainQueueBlock:^{
        return;
    }];
    XCTAssertNotNil(operation4);

    group = [[VDSGroupOperation alloc] initWithOperations:@[operation1, operation2, operation3, operation4]];
    XCTAssertNotNil(group);
    XCTAssertEqual(group.internalQueue.operationCount, 5);
    XCTAssertEqual(group.internalQueue.operations[1], operation1);
    XCTAssertEqual(group.internalQueue.operations[2], operation2);
    XCTAssertEqual(group.internalQueue.operations[3], operation3);
    XCTAssertEqual(group.internalQueue.operations[4], operation4);

    operation1 = [NSOperation new];
    XCTAssertNotNil(operation1);
    operation2 = [NSBlockOperation new];
    XCTAssertNotNil(operation2);
    [operation2 addExecutionBlock:^{
        return;
    }];
    operation3 = [VDSOperation new];
    XCTAssertNotNil(operation3);
    operation4 = [[VDSBlockOperation alloc] initWithMainQueueBlock:^{
        return;
    }];
    XCTAssertNotNil(operation4);

    group = [VDSGroupOperation initWithOperations:operation1, operation2, operation3, operation4, nil];
    XCTAssertNotNil(group);
    XCTAssertEqual(group.internalQueue.operationCount, 5);
    XCTAssertEqual(group.internalQueue.operations[1], operation1);
    XCTAssertEqual(group.internalQueue.operations[2], operation2);
    XCTAssertEqual(group.internalQueue.operations[3], operation3);
    XCTAssertEqual(group.internalQueue.operations[4], operation4);

}

- (void)testBasicRun {
    VDSGroupOperation* group = [VDSGroupOperation new];

    NSOperation* operation1 = [NSOperation new];
    XCTAssertNotNil(operation1);
    NSBlockOperation* operation2 = [NSBlockOperation new];
    XCTAssertNotNil(operation2);
    [operation2 addExecutionBlock:^{
        return;
    }];
    VDSOperation* operation3 = [VDSOperation new];
    XCTAssertNotNil(operation3);
    VDSBlockOperation* operation4 = [[VDSBlockOperation alloc] initWithMainQueueBlock:^{
        return;
    }];
    XCTAssertNotNil(operation4);
    
    [group addOperations:@[operation1, operation2, operation3, operation4]];
    
    VDSOperationQueue* queue = [VDSOperationQueue new];
    

    XCTKVOExpectation* expect = [[XCTKVOExpectation alloc] initWithKeyPath:NSStringFromSelector(@selector(operationCount)) object:group.internalQueue expectedValue:@(0)];
    XCTWaiter* waiter = [[XCTWaiter alloc] initWithDelegate:self];
    
    [queue addOperation:group];
    
    [waiter waitForExpectations:@[expect] timeout:10.0];
    XCTAssertEqual(operation1.isFinished, YES);
    XCTAssertEqual(operation2.isFinished, YES);
    XCTAssertEqual(operation3.isFinished, YES);
    XCTAssertEqual(operation4.isFinished, YES);
}

@end

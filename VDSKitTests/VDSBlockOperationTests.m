//
//  VDSBlockOperationTests.m
//  VDSKitTests
//
//  Created by Erikheath Thomas on 5/2/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "../VDSKit/VDSKit.h"

@interface VDSBlockOperationTests : XCTestCase

@end

@implementation VDSBlockOperationTests

- (void)testBasicInit {
    XCTAssertThrowsSpecificNamed([VDSBlockOperation new], NSException, NSInternalInconsistencyException);
    
    XCTAssertThrowsSpecificNamed([[VDSBlockOperation alloc] initWithBlock:nil], NSException, NSInternalInconsistencyException);
    
    XCTAssertThrowsSpecificNamed([[VDSBlockOperation alloc] initWithMainQueueBlock:nil], NSException, NSInternalInconsistencyException);
    
    void(^block)(void(^)(void)) = ^(void(^finishBlock)(void)){
        return;
    };
    
    VDSBlockOperation* operation = [[VDSBlockOperation alloc] initWithBlock:block];
    XCTAssertNotNil(operation.task);
    XCTAssertEqual(operation.task, block);
    
}

- (void)testBlockAssignment {
    XCTestExpectation* expect = [[XCTestExpectation alloc] initWithDescription:@"Block Executed."];
    XCTWaiter* waiter = [[XCTWaiter alloc] initWithDelegate:self];
    void(^block)(void(^)(void)) = ^(void(^finishBlock)(void)){
        [expect fulfill];
        return;
    };
    
    VDSBlockOperation* operation = [[VDSBlockOperation alloc] initWithBlock:block];
    VDSOperationQueue* queue = [VDSOperationQueue new];
    
    [queue addOperation:operation];
    [waiter waitForExpectations:@[expect] timeout:3];

}

- (void)testMainQueueAssignment {
    XCTestExpectation* expect = [[XCTestExpectation alloc] initWithDescription:@"Block Executed."];
    XCTWaiter* waiter = [[XCTWaiter alloc] initWithDelegate:self];
    void(^block)(void) = ^{
        if ([[NSThread currentThread] isMainThread]) { [expect fulfill]; }
        return;
    };
    
    VDSBlockOperation* operation = [[VDSBlockOperation alloc] initWithMainQueueBlock:block];
    VDSOperationQueue* queue = [VDSOperationQueue new];
    
    [queue addOperation:operation];
    [waiter waitForExpectations:@[expect] timeout:3];
}


@end

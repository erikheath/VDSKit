//
//  VDSOperationQueueTests.m
//  VDSKitTests
//
//  Created by Erikheath Thomas on 5/2/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "../../VDSKit/VDSKit.h"

@interface VDSOperationQueueTests : XCTestCase

@end

@implementation VDSOperationQueueTests

- (void)testBasicInit {
    VDSOperationQueue* queue = [VDSOperationQueue new];
    XCTAssertNotNil(queue);
    XCTAssertEqual(queue.operations.count, 0);
    XCTAssertNil(queue.delegate);
    
    id object = [NSObject new];
    queue.delegate = object;
    XCTAssertEqual(object, queue.delegate);
}

- (void)testAddOperation {
    VDSOperationQueue* queue = [VDSOperationQueue new];
    VDSOperation* operation = [VDSOperation new];
    
    [queue setSuspended:YES];
    XCTAssertEqual(queue.isSuspended, YES);
    XCTAssertEqual(queue.operations.count, 0);
    [queue addOperation:operation];
    XCTAssertEqual(queue.operations.count, 1);
    
    NSOperation* operation1 = [NSOperation new];
    XCTAssertNotNil(operation1);
    [queue addOperation:operation1];
    XCTAssertEqual(queue.operations.count, 2);
    XCTAssertEqual(queue.operations[0], operation);
    XCTAssertEqual(queue.operations[1], operation1);
}

- (void)testAddOperations {
    VDSOperationQueue* queue = [VDSOperationQueue new];
    VDSOperation* operation0 = [VDSOperation new];
    NSOperation* operation1 = [NSOperation new];
    NSOperation* opertion2 = [NSOperation new];
    
    [queue setSuspended:YES];
    XCTAssertEqual(queue.isSuspended, YES);
    XCTAssertEqual(queue.operations.count, 0);
    [queue addOperations:@[operation0, operation1, opertion2]];
    XCTAssertEqual(queue.operations.count, 3);
    XCTAssertEqual(queue.operations[0], operation0);
    XCTAssertEqual(queue.operations[1], operation1);
    XCTAssertEqual(queue.operations[2], opertion2);
}

@end

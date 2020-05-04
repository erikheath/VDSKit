//
//  VDSOperationQueueTests.m
//  VDSKitTests
//
//  Created by Erikheath Thomas on 5/2/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "../VDSKit/VDSKit.h"

@interface VDSOperationQueueTests : XCTestCase

@end

@implementation VDSOperationQueueTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testBasicInit {
    VDSOperationQueue* queue = [VDSOperationQueue new];
    XCTAssertNotNil(queue);
    XCTAssertEqual(queue.operations.count, 0);
    XCTAssertNil(queue.delegate);
}

- (void)testAddOperation {
    VDSOperationQueue* queue = [VDSOperationQueue new];
    VDSOperation* operation = [VDSOperation new];
    
    [queue setSuspended:YES];
    XCTAssertEqual(queue.isSuspended, YES);
    XCTAssertEqual(queue.operations.count, 0);
    [queue addOperation:operation];
    XCTAssertEqual(queue.operations.count, 1);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

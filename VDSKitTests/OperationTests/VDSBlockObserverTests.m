//
//  VDSBlockObserverTests.m
//  VDSKitTests
//
//  Created by Erikheath Thomas on 5/2/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "../../VDSKit/VDSKit.h"

@interface VDSBlockObserverTests : XCTestCase

@end

@implementation VDSBlockObserverTests

- (void)testBasicInit {
    VDSBlockObserver* observer = [[VDSBlockObserver alloc] initWithStartOperationHandler:^(VDSOperation * _Nonnull startOperation) {
        return;
    } finishOperationHandler:^(VDSOperation * _Nonnull finishOperation) {
        return;
    }];
    XCTAssertNotNil(observer);
    XCTAssertNotNil(observer.didStartOperationHandler);
    XCTAssertNotNil(observer.didFinishOperationHandler);
    
    XCTAssertThrowsSpecific([[VDSBlockObserver alloc] init], NSException);

    
    XCTAssertThrowsSpecific([[VDSBlockObserver alloc] initWithStartOperationHandler:nil finishOperationHandler:nil], NSException);
    
    
}

- (void)testHandlers {
    BOOL __block startFlag = NO;
    BOOL __block finishFlag = NO;

    void(^start)(VDSOperation*) = ^(VDSOperation* operation){ startFlag = YES; };
    void(^finish)(VDSOperation*) = ^(VDSOperation* operation){ finishFlag = YES; };
    
    VDSBlockObserver* observer = [[VDSBlockObserver alloc] initWithStartOperationHandler:start  finishOperationHandler:finish];
    XCTAssertNotNil(observer);
    XCTAssertNotNil(observer.didStartOperationHandler);
    XCTAssertNotNil(observer.didFinishOperationHandler);
    XCTAssertEqual(observer.didStartOperationHandler, start);
    XCTAssertEqual(observer.didFinishOperationHandler, finish);
    
    VDSOperation* operation = [VDSOperation new];
    observer.didStartOperationHandler(operation);
    observer.didFinishOperationHandler(operation);
    XCTAssertTrue(startFlag);
    XCTAssertTrue(finishFlag);
    
}

@end

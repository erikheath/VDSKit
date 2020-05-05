//
//  VDSBlockObserverTests.m
//  VDSKitTests
//
//  Created by Erikheath Thomas on 5/2/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "../VDSKit/VDSKit.h"


@interface VDSBlockObserverTests : XCTestCase

@end

@implementation VDSBlockObserverTests

- (void)testBasicInit {
    VDSBlockObserver* observer = [[VDSBlockObserver alloc] initWithStartOperationHandler:^(VDSOperation * _Nonnull startOperation) {
        return;
    } produceOperationHandler:^(VDSOperation * _Nonnull originOperation, NSOperation * _Nonnull producedOperation) {
        return;
    } finishOperationHandler:^(VDSOperation * _Nonnull finishOperation) {
        return;
    }];
    XCTAssertNotNil(observer);
    XCTAssertNotNil(observer.didStartOperationHandler);
    XCTAssertNotNil(observer.didProduceOperationHandler);
    XCTAssertNotNil(observer.didFinishOperationHandler);
    
    XCTAssertThrowsSpecific([[VDSBlockObserver alloc] init], NSException);

    
    observer = [[VDSBlockObserver alloc] initWithStartOperationHandler:nil produceOperationHandler:nil finishOperationHandler:nil];
    XCTAssertNil(observer.didStartOperationHandler);
    XCTAssertNil(observer.didProduceOperationHandler);
    XCTAssertNil(observer.didFinishOperationHandler);
    
}

- (void)testHandlers {
    BOOL __block startFlag = NO;
    BOOL __block produceFlag = NO;
    BOOL __block finishFlag = NO;

    void(^start)(VDSOperation*) = ^(VDSOperation* operation){ startFlag = YES; };
    void(^produce)(VDSOperation*, NSOperation*) = ^(VDSOperation* operation, NSOperation* newOperation){ produceFlag = YES; };
    void(^finish)(VDSOperation*) = ^(VDSOperation* operation){ finishFlag = YES; };
    
    VDSBlockObserver* observer = [[VDSBlockObserver alloc] initWithStartOperationHandler:start produceOperationHandler:produce finishOperationHandler:finish];
    XCTAssertNotNil(observer);
    XCTAssertNotNil(observer.didStartOperationHandler);
    XCTAssertNotNil(observer.didProduceOperationHandler);
    XCTAssertNotNil(observer.didFinishOperationHandler);
    XCTAssertEqual(observer.didStartOperationHandler, start);
    XCTAssertEqual(observer.didProduceOperationHandler, produce);
    XCTAssertEqual(observer.didFinishOperationHandler, finish);
    
    VDSOperation* operation = [VDSOperation new];
    NSOperation* newOperation = [NSOperation new];
    observer.didStartOperationHandler(operation);
    observer.didProduceOperationHandler(operation, newOperation);
    observer.didFinishOperationHandler(operation);
    XCTAssertTrue(startFlag);
    XCTAssertTrue(produceFlag);
    XCTAssertTrue(finishFlag);
    
}

@end

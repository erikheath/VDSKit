//
//  VDSExpirableObjectTests.m
//  VDSKitTests
//
//  Created by Erikheath Thomas on 5/6/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "../../VDSKit/VDSKit.h"

@interface VDSExpirableObjectTests : XCTestCase

@end

@implementation VDSExpirableObjectTests

- (void)testBasicInit {
    // Test correct value types
    id object = [NSObject new];
    NSDate* date = [NSDate date];
    VDSExpirableObject* expirable = [[VDSExpirableObject alloc] initWithExpiration:date
                                                                        object:object];
    XCTAssertNotNil(expirable);
    XCTAssertEqual(object, expirable.object);
    XCTAssertEqual(date, expirable.expiration);
    XCTAssertTrue(expirable.isExpired);
    
    // Test nil values
    object = nil;
    date = nil;
    XCTAssertThrowsSpecificNamed([[VDSExpirableObject alloc] initWithExpiration:date object:object], NSException, NSInternalInconsistencyException);

    // Test wrong value type
    id nonDate = [NSObject new];
    object = [NSObject new];
    XCTAssertThrowsSpecificNamed([[VDSExpirableObject alloc] initWithExpiration:nonDate
                                                                         object:object], NSException, NSInternalInconsistencyException);
    
    // Test invalid init use
    XCTAssertThrowsSpecificNamed([[VDSExpirableObject alloc] init], NSException, NSInternalInconsistencyException);
    XCTAssertThrowsSpecificNamed([VDSExpirableObject new], NSException, NSInternalInconsistencyException);
    
}

- (void)testConfigInit {
    // Test correct keys
    VDSExpirableObject* expirable = nil;
    id object = [NSObject new];
    NSDate* date = [NSDate date];
    NSDictionary* dictionary = @{@"expiration": date, @"object": object};
    expirable = [[VDSExpirableObject alloc] initWithConfiguration:dictionary];

    XCTAssertNotNil(expirable);
    XCTAssertEqual(object, expirable.object);
    XCTAssertEqual(date, expirable.expiration);
    XCTAssertTrue(expirable.isExpired);

    // Test incorrect keys
    expirable = nil;
    dictionary = nil;
    
    dictionary = @{@"wrongKey1": date, @"wrongKey2": object};
    XCTAssertThrowsSpecificNamed([[VDSExpirableObject alloc] initWithConfiguration:dictionary], NSException, NSInternalInconsistencyException);

}

- (void)testClassConfigInit {
    // Test correct keys
     VDSExpirableObject* expirable = nil;
    id object = [NSObject new];
    NSDate* date = [NSDate date];
    NSDictionary* dictionary = @{@"expiration": date, @"object": object};
    expirable = [VDSExpirableObject initWithConfiguration:dictionary];

    XCTAssertNotNil(expirable);
    XCTAssertEqual(object, expirable.object);
    XCTAssertEqual(date, expirable.expiration);
    XCTAssertTrue(expirable.isExpired);

    // Test incorrect keys
    expirable = nil;
    dictionary = nil;
    
    dictionary = @{@"wrongKey1": date, @"wrongKey2": object};
    XCTAssertThrowsSpecificNamed([VDSExpirableObject initWithConfiguration:dictionary], NSException, NSInternalInconsistencyException);

}

- (void)testExpiration {
    // Test the future
    id object = [NSObject new];
    NSDate* date = [NSDate distantFuture];
    VDSExpirableObject* expirable = [[VDSExpirableObject alloc] initWithExpiration:date
                                                                        object:object];
    XCTAssertNotNil(expirable);
    XCTAssertEqual(object, expirable.object);
    XCTAssertEqual(date, expirable.expiration);
    XCTAssertFalse(expirable.isExpired);

    // Test the past
    expirable = nil;
    date = [NSDate distantPast];
    expirable = [[VDSExpirableObject alloc] initWithExpiration:date
                                                        object:object];
    XCTAssertNotNil(expirable);
    XCTAssertEqual(object, expirable.object);
    XCTAssertEqual(date, expirable.expiration);
    XCTAssertTrue(expirable.isExpired);

    // Test immediate expiration
    expirable = nil;
    date = [NSDate date];
    expirable = [[VDSExpirableObject alloc] initWithExpiration:date
                                                        object:object];
    XCTAssertNotNil(expirable);
    XCTAssertEqual(object, expirable.object);
    XCTAssertEqual(date, expirable.expiration);
    XCTAssertTrue(expirable.isExpired);

}


@end

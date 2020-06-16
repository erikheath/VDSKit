//
//  VDSDatabaseCacheTests.m
//  VDSKitTests
//
//  Created by Erikheath Thomas on 5/6/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "../../VDSKit/VDSKit.h"


@interface VDSDatabaseCacheTests : XCTestCase

@end

@implementation VDSDatabaseCacheTests

- (void)testBasicInit
{
    VDSDatabaseCache* cache = [VDSDatabaseCache new];
    XCTAssertNotNil(cache);
    XCTAssertNil(cache.delegate);
    XCTAssertNotNil(cache.configuration);
    
    // Confirm the configuration
    XCTAssertFalse(cache.configuration.expiresObjects);
    XCTAssertFalse(cache.configuration.archivesUntrackedObjects);
    XCTAssertFalse(cache.configuration.evictsOnLowMemory);
    XCTAssertTrue(cache.configuration.replacesObjectsOnUpdate);
    XCTAssertFalse(cache.configuration.tracksObjectUsage);
    XCTAssertFalse(cache.configuration.evictsObjectsInUse);
    XCTAssert(cache.configuration.preferredMaxObjectCount == 0);
    XCTAssert(cache.configuration.evictionPolicy == VDSFIFOPolicy);
    XCTAssert(cache.configuration.evictionInterval == 0.0);
    XCTAssertNil(cache.configuration.expirationTimingMapKey);
    XCTAssertNil(cache.configuration.expirationTimingMap);
}

- (void)testCustomBasicInit
{
    VDSDatabaseCache* cache = [[VDSDatabaseCache alloc] initWithConfiguration:[VDSDatabaseCacheConfiguration new]];
    XCTAssertNotNil(cache);
    XCTAssertNil(cache.delegate);
    XCTAssertNotNil(cache.configuration);
    
    // Confirm the configuration
    XCTAssertFalse(cache.configuration.expiresObjects);
    XCTAssertFalse(cache.configuration.archivesUntrackedObjects);
    XCTAssertFalse(cache.configuration.evictsOnLowMemory);
    XCTAssertTrue(cache.configuration.replacesObjectsOnUpdate);
    XCTAssertFalse(cache.configuration.tracksObjectUsage);
    XCTAssertFalse(cache.configuration.evictsObjectsInUse);
    XCTAssert(cache.configuration.preferredMaxObjectCount == 0);
    XCTAssert(cache.configuration.evictionPolicy == VDSFIFOPolicy);
    XCTAssert(cache.configuration.evictionInterval == 0.0);
    XCTAssertNil(cache.configuration.expirationTimingMapKey);
    XCTAssertNil(cache.configuration.expirationTimingMap);

}

- (void)testCustomInitWithExpiration
{
    VDSMutableDatabaseCacheConfiguration* config = [VDSMutableDatabaseCacheConfiguration new];
    config.expiresObjects = YES;
    config.evictionInterval = 0;
    VDSDatabaseCache* cache = [[VDSDatabaseCache alloc] initWithConfiguration:config];
    cache.defaultExpirationInterval = 300;
    
    // Confirm the configuration
    XCTAssertTrue(cache.configuration.expiresObjects);
    
    NSObject* object = [NSObject new];
    NSString* key1 = @"testObj1";
    [cache setObject:object forKey:key1];
    
    XCTAssertEqual(object, [cache objectForKey:key1]);
    XCTAssertFalse([[cache trackedObjects] containsObject:object]);
    XCTAssertTrue([[cache untrackedObjects] containsObject:object]);
    XCTAssertTrue([[cache allObjects] containsObject:object]);
    XCTAssertTrue([[cache allKeys] containsObject:key1]);
    XCTAssertFalse([[cache trackedKeys] containsObject:key1]);
    XCTAssertTrue([[cache untrackedKeys] containsObject:key1]);
    XCTAssertEqual([[cache trackedObjectsAndKeys] count], 0);
    XCTAssertEqual([[cache untrackedObjectsAndKeys] count], 1);
    XCTAssertEqualObjects([[[cache untrackedObjectsAndKeys] allKeys] firstObject], key1);
    XCTAssertEqualObjects([[[cache untrackedObjectsAndKeys] allValues] firstObject], object);
}

- (void)testCustomInitWithUsageTracking
{
    
}



@end

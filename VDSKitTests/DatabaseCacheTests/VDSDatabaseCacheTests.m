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
    
}

- (void)testCustomInitWithUsageTracking
{
    
}



@end

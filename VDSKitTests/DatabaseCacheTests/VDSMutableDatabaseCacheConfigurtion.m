//
//  VDSMutableDatabaseCacheConfigurtion.m
//  VDSKitTests
//
//  Created by Erikheath Thomas on 5/29/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "../../VDSKit/VDSKit.h"





@interface VDSMutableDatabaseCacheConfigurtion : XCTestCase

@end

@implementation VDSMutableDatabaseCacheConfigurtion

- (void)testBasicInit
{
    VDSMutableDatabaseCacheConfiguration* config = [[VDSMutableDatabaseCacheConfiguration alloc] init];
    XCTAssertNotNil(config);
    XCTAssertFalse(config.expiresObjects);
    XCTAssertTrue(config.archivesUntrackedObjects);
    XCTAssertFalse(config.evictsOnLowMemory);
    XCTAssertTrue(config.replacesObjectsOnUpdate);
    XCTAssertFalse(config.tracksObjectUsage);
    XCTAssertFalse(config.evictsObjectsInUse);
    XCTAssert(config.preferredMaxObjectCount == 0);
    XCTAssert(config.evictionPolicy == VDSFIFOPolicy);
    XCTAssert(config.evictionInterval == 0.0);
    XCTAssertNil(config.expirationTimingMapKey);
    XCTAssertNil(config.expirationTimingMap);
    
    config = nil;
    config = [VDSMutableDatabaseCacheConfiguration new];
    XCTAssertNotNil(config);
    XCTAssertFalse(config.expiresObjects);
    XCTAssertTrue(config.archivesUntrackedObjects);
    XCTAssertFalse(config.evictsOnLowMemory);
    XCTAssertTrue(config.replacesObjectsOnUpdate);
    XCTAssertFalse(config.tracksObjectUsage);
    XCTAssertFalse(config.evictsObjectsInUse);
    XCTAssert(config.preferredMaxObjectCount == 0);
    XCTAssert(config.evictionPolicy == VDSFIFOPolicy);
    XCTAssert(config.evictionInterval == 0.0);
    XCTAssertNil(config.expirationTimingMapKey);
    XCTAssertNil(config.expirationTimingMap);
    
}

- (void)testInitWithValues
{
    NSExpression* expression = [NSExpression expressionWithFormat:@"SELF"];
    NSDictionary* expressionMap = @{@"SELF": expression};
    
    NSDictionary* configDict = @{VDSCacheExpiresObjectsKey: @NO,
                                 VDSCacheArchivesUntrackedObjectsKey: @YES,
                                 VDSCacheEvictsOnLowMemoryKey: @YES,
                                 VDSCacheReplacesObjectsOnUpdateKey: @NO,
                                 VDSCacheTracksObjectUsageKey: @YES,
                                 VDSCacheEvictsObjectsInUseKey: @YES,
                                 VDSCachePreferredMaxObjectCountKey: @50,
                                 VDSCacheEvictionPolicyKey: @(VDSFIFOPolicy),
                                 VDSCacheEvictionIntervalKey: @(300.0),
                                 VDSCacheExpirationTimingMapExpressionKey: expression,
                                 VDSCacheExpirationTimingMapKey: expressionMap
    };
    
    VDSMutableDatabaseCacheConfiguration* config = [[VDSMutableDatabaseCacheConfiguration alloc] initWithDictionary:configDict];
    XCTAssertNotNil(config);
    XCTAssertFalse(config.expiresObjects);
    XCTAssertTrue(config.archivesUntrackedObjects);
    XCTAssertTrue(config.evictsOnLowMemory);
    XCTAssertFalse(config.replacesObjectsOnUpdate);
    XCTAssertTrue(config.tracksObjectUsage);
    XCTAssertTrue(config.evictsObjectsInUse);
    XCTAssert(config.preferredMaxObjectCount == 50);
    XCTAssert(config.evictionPolicy == VDSFIFOPolicy);
    XCTAssert(config.evictionInterval == 300.0);
    XCTAssertNotNil(config.expirationTimingMapKey);
    XCTAssertNotNil(config.expirationTimingMap);
    XCTAssertEqualObjects(expression, config.expirationTimingMapKey);
    XCTAssertEqualObjects(expressionMap, config.expirationTimingMap);
    
    config.expiresObjects = YES;
    XCTAssertTrue(config.expiresObjects);
    
    config.archivesUntrackedObjects = YES;
    XCTAssertTrue(config.archivesUntrackedObjects);

    config.evictsOnLowMemory = YES;
    XCTAssertTrue(config.evictsOnLowMemory);

    config.replacesObjectsOnUpdate = YES;
    XCTAssertTrue(config.replacesObjectsOnUpdate);

    config.tracksObjectUsage = YES;
    XCTAssertTrue(config.tracksObjectUsage);

    config.evictsObjectsInUse = YES;
    XCTAssertTrue(config.evictsObjectsInUse);

    config.preferredMaxObjectCount = 3000;
    XCTAssertEqual(config.preferredMaxObjectCount, 3000);
    
    config.evictionPolicy = VDSLIFOPolicy;
    XCTAssertEqual(config.evictionPolicy, VDSLIFOPolicy);
    
    config.evictionInterval = 225.0;
    XCTAssertEqual(config.evictionInterval, 225.0);
    
    config.expirationTimingMapKey = nil;
    XCTAssertNil(config.expirationTimingMapKey);
    
    config.expirationTimingMap = nil;
    XCTAssertNil(config.expirationTimingMap);
}

@end

//
//  VDSDatabaseCacheConfigurationTests.m
//  VDSKitTests
//
//  Created by Erikheath Thomas on 5/29/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "../../VDSKit/VDSKit.h"

@interface VDSDatabaseCacheConfigurationTests : XCTestCase

@end

@implementation VDSDatabaseCacheConfigurationTests


- (void)testBasicInit
{
    VDSDatabaseCacheConfiguration* config = [[VDSDatabaseCacheConfiguration alloc] initWithDictionary:@{}];
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
    config = [VDSDatabaseCacheConfiguration new];
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
    
    VDSDatabaseCacheConfiguration* config = [[VDSDatabaseCacheConfiguration alloc] initWithDictionary:configDict];
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
}

@end



//
//  VDSDatabaseCacheTests.m
//  VDSKitTests
//
//  Created by Erikheath Thomas on 5/6/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "../../VDSKit/VDSKit.h"


/// TODO: Add test for set with expiry, process evictions, track usage


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
    config.evictionInterval = 6000;
    VDSDatabaseCache* cache = [[VDSDatabaseCache alloc] initWithConfiguration:config];
    cache.defaultExpirationInterval = 3000;
    
    /// Confirm the configuration
    XCTAssertTrue(cache.configuration.expiresObjects);
    XCTAssertEqual(cache.defaultExpirationInterval, 3000);
    XCTAssertEqual(cache.configuration.evictionInterval, 6000);
    
    
    /// Add a single object to the cache
    NSObject* object = [NSObject new];
    NSString* key = @"testObj";
    [cache setObject:object forKey:key];
    
    XCTAssertEqual(object, [cache objectForKey:key]);
    XCTAssertFalse([[cache trackedObjects] containsObject:object]);
    XCTAssertTrue([[cache untrackedObjects] containsObject:object]);
    XCTAssertTrue([[cache allObjects] containsObject:object]);
    XCTAssertTrue([[cache allKeys] containsObject:key]);
    XCTAssertFalse([[cache trackedKeys] containsObject:key]);
    XCTAssertTrue([[cache untrackedKeys] containsObject:key]);
    XCTAssertEqual([[cache trackedObjectsAndKeys] count], 0);
    XCTAssertEqual([[cache untrackedObjectsAndKeys] count], 1);
    XCTAssertEqualObjects([[[cache untrackedObjectsAndKeys] allKeys] firstObject], key);
    XCTAssertEqualObjects([[[cache untrackedObjectsAndKeys] allValues] firstObject], object);
    XCTAssertEqual([[cache allObjectsAndKeys] count], 1);
    XCTAssertEqualObjects([[[cache allObjectsAndKeys] allKeys] firstObject], key);
    XCTAssertEqualObjects([[[cache allObjectsAndKeys] allValues] firstObject], object);
    XCTAssertFalse([cache incrementUsageCount:object]);
    XCTAssertFalse([cache decrementUsageCount:object]);
    
    /// Empty the cache
    [cache removeObjectForKey:key];
    
    XCTAssertFalse([[cache trackedObjects] containsObject:object]);
    XCTAssertFalse([[cache untrackedObjects] containsObject:object]);
    XCTAssertFalse([[cache allObjects] containsObject:object]);
    XCTAssertFalse([[cache allKeys] containsObject:key]);
    XCTAssertFalse([[cache trackedKeys] containsObject:key]);
    XCTAssertFalse([[cache untrackedKeys] containsObject:key]);
    XCTAssertEqual([[cache trackedObjectsAndKeys] count], 0);
    XCTAssertEqual([[cache untrackedObjectsAndKeys] count], 0);
    XCTAssertEqual([[cache allObjectsAndKeys] count], 0);

    /// Fill the cache with multiple objects
    NSObject* object1 = [NSObject new];
    NSObject* object2 = [NSObject new];
    NSObject* object3 = [NSObject new];
    
    NSString* key1 = @"testKey1";
    NSString* key2 = @"testKey2";
    NSString* key3 = @"testKey3";
    
    [cache setObject:object1 forKey:key1];
    [cache setObject:object2 forKey:key2];
    [cache setObject:object3 forKey:key3];
    
    XCTAssertEqual(object1, [cache objectForKey:key1]);
    XCTAssertEqual(object2, [cache objectForKey:key2]);
    XCTAssertEqual(object3, [cache objectForKey:key3]);
    XCTAssertNotEqualObjects(object1, [cache objectForKey:key2]);
    XCTAssertNotEqualObjects(object2, [cache objectForKey:key3]);
    XCTAssertNotEqualObjects(object3, [cache objectForKey:key1]);

    NSSet* objectSet = [NSSet setWithArray:@[object1, object2, object3]];
    NSSet* keySet = [NSSet setWithArray:@[key1, key2, key3]];
    XCTAssertFalse([objectSet isSubsetOfSet:[NSSet setWithArray:[cache trackedObjects]]]);
    XCTAssertTrue([objectSet isSubsetOfSet:[NSSet setWithArray:[cache untrackedObjects]]]);
    XCTAssertTrue([objectSet isSubsetOfSet:[NSSet setWithArray:[cache allObjects]]]);
    XCTAssertTrue([keySet isSubsetOfSet:[NSSet setWithArray:[cache allKeys]]]);
    XCTAssertFalse([keySet isSubsetOfSet:[NSSet setWithArray:[cache trackedKeys]]]);
    XCTAssertTrue([keySet isSubsetOfSet:[NSSet setWithArray:[cache untrackedKeys]]]);
    XCTAssertEqual([[cache trackedObjectsAndKeys] count], 0);
    XCTAssertEqual([[cache untrackedObjectsAndKeys] count], 3);
    XCTAssertEqualObjects([NSSet setWithArray:[[cache untrackedObjectsAndKeys] allKeys]], keySet);
    XCTAssertEqualObjects([NSSet setWithArray:[[cache untrackedObjectsAndKeys] allValues]], objectSet);
    XCTAssertEqual([[cache allObjectsAndKeys] count], 3);
    XCTAssertEqualObjects([NSSet setWithArray:[[cache allObjectsAndKeys] allKeys]], keySet);
    XCTAssertEqualObjects([NSSet setWithArray:[[cache allObjectsAndKeys] allValues]], objectSet);
    XCTAssertFalse([cache incrementUsageCount:object2]);
    XCTAssertFalse([cache decrementUsageCount:object3]);

    
    /// Remove all objects
    [cache removeAllObjects];
    
    XCTAssertFalse([[cache trackedObjects] containsObject:object]);
    XCTAssertFalse([[cache untrackedObjects] containsObject:object]);
    XCTAssertFalse([[cache allObjects] containsObject:object]);
    XCTAssertFalse([[cache allKeys] containsObject:key]);
    XCTAssertFalse([[cache trackedKeys] containsObject:key]);
    XCTAssertFalse([[cache untrackedKeys] containsObject:key]);
    XCTAssertEqual([[cache trackedObjectsAndKeys] count], 0);
    XCTAssertEqual([[cache untrackedObjectsAndKeys] count], 0);
    XCTAssertEqual([[cache allObjectsAndKeys] count], 0);

}

- (void)testCustomInitWithUsageTracking
{
    
}



@end

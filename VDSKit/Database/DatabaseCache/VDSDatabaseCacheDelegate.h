//
//  VDSDatabaseCacheDelegate.h
//  VDSKit
//
//  Created by Erikheath Thomas on 5/7/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

@import Foundation;


#pragma mark - VDSDatabaseCacheDelegate -


/// @summary Objects that conform to the VDSDatabaseCacheDelegate protocol can receive messages
/// from a VDSDatabaseCache when the cache engages in its eviction processing.
///
@protocol VDSDatabaseCacheDelegate <NSCacheDelegate>

@optional

/// @summary Allows the delegate to force the cache to skip the current scheduled eviction cycle.
///
/// @returns Return YES to allow the cycle to proceed, NO to force the cache to skip the eviction cycle.
///
- (BOOL)databaseCacheShouldBeginEvictionCycle;


/// @summary Notifies the delegate that an eviction cycle of type 'cycleKey' is about to begin.
///
/// @param cache The database cache that will be evicting objects.
///
/// @param cycleKey The type of eviction cycle that will be used to evict objects.
///
- (void)databaseCache:(VDSDatabaseCache* _Nonnull)cache
    willBeginEvictionCycle:(VDSEvictionCycleKey _Nonnull)cycleKey;


/// @summary Notifies the delegate that the eviction cycle of type 'cycleKey' has completed.
///
/// @param cache The database cache that evicted objects
///
/// @param cycleKey The type of eviction cycle that was used to evict objects.
///
- (void)databaseCache:(VDSDatabaseCache* _Nonnull)cache
    didCompleteEvictionCycle:(VDSEvictionCycleKey _Nonnull)cycleKey;


/// @summary Allows the delegate to determine if a specific object should be evicted from the database cache.
///
/// @param cache The database cache that will be evicting objects.
///
/// @param object The object from the database cache that will be evicted.
///
/// @param cacheKey The used by the database cache to store the object.
///
/// @param cycleKey The type of eviction cycle that is being used to evict the object.
///
- (BOOL)databaseCache:(VDSDatabaseCache* _Nonnull)cache
    shouldEvictObject:(id _Nonnull)object
             usingKey:(id _Nonnull)cacheKey
      inEvictionCycle:(VDSEvictionCycleKey _Nonnull)cycleKey;


/// @summary Notifies the delegate that a set of objects will be evicted from the database cache.
///
/// @param cache The database cache that will be evicting objects.
///
/// @param objects The objects from the database cache that will be evicted.
///
/// @param cacheKeys The keys used by the database cache to store the objects.
///
/// @param cycleKey The type of eviction cycle that is being used to evict the objects.
///
- (void)databaseCache:(VDSDatabaseCache* _Nonnull)cache
     willEvictObjects:(NSArray* _Nonnull)objects
            usingKeys:(NSArray* _Nonnull)cacheKeys
      inEvictionCycle:(VDSEvictionCycleKey _Nonnull)cycleKey;


/// @summary Notifies the delegate that a set of objects was evicted from the datbase cache.
///
/// @param cache The database cache that evicted the objects.
///
/// @param objects The objects that were evicted from the database cache.
///
/// @param cacheKeys The keys used by the database cache to store the evicted objects.
///
/// @param cycleKey The type of eviction cycle that is being used to evict the objects.
/// 
- (void)databaseCache:(VDSDatabaseCache* _Nonnull)cache
      didEvictObjects:(NSArray* _Nonnull)objects
            usingKeys:(NSArray* _Nonnull)cacheKeys
      inEvictionCycle:(VDSEvictionCycleKey _Nonnull)cycleKey;


@end

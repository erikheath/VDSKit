//
//  VDSDatabaseCache.h
//  VDSKit
//
//  Created by Erikheath Thomas on 4/20/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

@import Foundation;

#import "VDSConstants.h"

@class VDSDatabaseCache;
@class VDSDatabaseCacheConfiguration;
@class VDSExpirableObject;
@protocol VDSDatabaseCacheDelegate;
@protocol VDSMergableObject;



#pragma mark - VDSDatabaseCache -

/// @summary VDSDatabaseCache provides a subclassable, enumerable, and archivable object caching system.
/// The class provides object tracking using expiration, usage, and/or max object counts and supports
/// mixing of tracked and untracked objects for maximum caching flexibility. Adding and evicting methods
/// are thread safe, as are all cache configuration properties. The class may be used as is, may be
/// safely subclassed, or may be used as a backing class for a facade that limits direct cache storage
/// manipulation to facade internals.
///
/// @discussion VDSDatabaseCache supports fast enumeration over the contents contained in its cachedObjects
/// To enumerate only those items that are tracked, use either trackedObjectsAndKeys or trackedObjects.
/// To enumerate over the items that are not tracked, use untrackedObjectsAndKeys or untrackedObjects.
///
/// The cache also supports archiving of untracked objects when archivesUntrackedObjects is set to YES. To
/// archive tracked objects, create a subclass of VDSDatabaseCache and override initWithCoder: and
/// encodeWithCoder:, calling the super class methods to encode the configuration (and untracked objects
/// if desired).
///
/// When encoding, use trackedObjectsAndKeys to iterate and create a new dictionary of only the tracked
/// objects that can be encoded. When decoding in the initWithCoder: method,
/// make sure to use the setObject:forKey:tracked method to add the objects to the cachedObjects internal
/// tracking system. Otherwise the formerly tracked objects will become untracked.
///
/// @note Archiving tracked objects can become complicated when expiration is determined by an external
/// source, such as a remote store or web service. In these instances, it is genrally a good idea to rerequest
/// all of the cached items last-updated timestamps and compare them to the timestamps of the objects
/// that have been loaded into the cache. Objects that are no longer valid (i.e. don't exist) can be
/// removed from the cache. Objects that exist but need to be refreshed can be requested in full and then
/// updated. This process enables you to have data immediately available, while only updating objects where data
/// has actually changed.
///
@interface VDSDatabaseCache : NSObject <NSFastEnumeration, NSSecureCoding> {
    
}


#pragma mark Delegation

/// @summary A delegate object that conforms to VDSDatabaseCacheDelegate. Use the delegate to
/// control when/if evictions take place and which objects will be evicted.
///
@property(weak, readwrite, nullable) id<VDSDatabaseCacheDelegate> delegate;


#pragma mark Cache Configuration

/// The configuration object used by the cache to configure itself. The cache makes a copy
/// of any configuration object passed to it during initialization. This copy is the object
/// that is returned from this property.
@property(strong, readonly, nonnull, nonatomic) VDSDatabaseCacheConfiguration* configuration;


#pragma mark Object Lifecycle

/// @summary Creates a new database cache using the default configuration.
///
/// @discussion The default configuration consists of a cache that does not expire, track, or
/// evict objects, does not have a maximum size, and will not archive untracked objects.
///
/// @returns An instance of the cache using the default configuration.
///
- (instancetype _Nonnull)init;


/// @summary Creates a new database cache using the configuration specified by the configuration.
/// To create a cache with a default configuration, use init.
///
/// @param configuration A VDSDatabaseCacheConfiguration.
///
/// @returns An instance of the cache using the provided configuration.
///
- (instancetype _Nonnull)initWithConfiguration:(VDSDatabaseCacheConfiguration* _Nullable)configuration NS_DESIGNATED_INITIALIZER;


#pragma mark Eviction Behaviors

/// @summary Immediately attempts to launch the eviction process on the eviction queue. This
/// method does not indicate that evictions were completed successfully, only that an eviction
/// operation has been created and placed on the eviction queue.
///
/// @discussion Evictions are performed in a series cancellable operations: one for expired objects, one
/// for cache size maintainance, and one for usage. Subclasses can add eviction operations
/// or override the dependency chain to reorder, and therefore reprioritize how the eviction
/// process works. For more information, refer to the class documentation for
/// VDSEvictionOperation.
///
/// This method is triggered by the evictionLoop timer periodically according to the evictionInterval
/// property.
///
/// @param timer The timer that triggered the execution of the method.
///
- (void)processEvictions:(NSTimer* _Nonnull)timer;


/// @summary Attempts to evict objects from the cache that meet the eviction criteria
/// specified in the configuration.
///
/// @discussion The cache takes an aggressive approach, removing objects that are
/// unused and expired, according to the eviction policy, regardless of the max object count.
///
/// The database cache will decrement the object count for any object that has expired.
/// If the cache is configured to track uses and the object has no additional uses,
/// then the object will be removed.
///
/// If cache is configured to remove items that have expired regardless of use,
/// then the expired object will be removed. Otherwise, it will be left in the cache.
///
/// If the object has not expired but has no users, then the object will be removed if
/// the cache exceeds the max object count. Otherwise, the object will be left in the cache.
///
- (void)processCacheEvictions;


#pragma mark Usage Count Behaviors

/// @summary Increments the usage counter for the object associated with the key.
///
/// @param key The unique identifier used to store the object in the cache.
///
/// @returns YES if the usage counter was incremented successfully, NO otherwise.
///
- (BOOL)incrementUsageCount:(id _Nonnull)key;


/// Decrements the usage counter for the object associated with the key.
///
/// @param key The unique identifier used to store the object in the cache.
///
/// @returns YES if the usage counter was decremented successfully, NO otherwise.
///
- (BOOL)decrementUsageCount:(id _Nonnull)key;


#pragma mark Object Storage Behaviors

/// @summary Adds an object to the cache without tracking, and if necessary evicts
/// an existing object according to the cache configuration.
///
/// @note This method calls setObject:forKey:tracked setting the tracked parameter
/// argument to NO.
///
/// @param object A nonnull object to be tracked by the cache.
///
/// @param key A nonnull unique key that should be associated with the object.
/// If the key already exists in the cache, the new object is treated as
/// an update and the values of the new object are either merged with the existing object
/// or the object is replaced by the new object according to the cache configuration.
///
- (void)setObject:(id _Nonnull)object forKey:(id _Nonnull)key;


/// @summary Adds an object to the cache, optionally tracks, and if necessary evicts
/// an existing object according to the cache configuration.
///
/// @param object A nonnull object to be tracked by the cache.
///
/// @param key A nonnull unique key that should be associated with the object
/// being tracked. If the key already exists in the cache, the new object is treated as
/// an update and the values of the new object are either merged with the existing object
/// or the object is replaced by the new object according to the cache configuration.
///
/// @param tracked YES if the object should be tracked, NO otherwise.
///
- (void)setObject:(id _Nonnull)object forKey:(id _Nonnull)key tracked:(BOOL)tracked;


/// Removes an object from the cache.
///
/// @param key The unique key associated with the object in the cache.
///
- (void)removeObjectForKey:(id _Nonnull)key;


/// Clears all objects in the cache.
///
- (void)removeAllObjects;


#pragma mark Object Access Behaviors

/// Retrieves an object from the cache if it exists. Returns nil otherwise.
///
/// @param key A key used to store an object in the cache.
///
/// @returns An object if found, otherwise nil.
///
- (id _Nullable)objectForKey:(id _Nonnull)key;


/// Returns all cached objects.
///
/// @returns A NSArray containing any cached objects. If no cached objects
/// exist, the array is empty.
- (NSArray* _Nonnull)allObjects;


/// Returns all cached objects that are tracked.
///
/// @warning If the returned array contains an NSNull instance, it means that an error has
/// occurred in caching an object associated with one or more of the keys.
///
/// @returns A NSArray containing any tracked cached objects. If no tracked cached objects
/// exist, the array is empty.
- (NSArray* _Nonnull)trackedObjects;


/// Returns all untracked cached objects.
///
/// @warning If the returned array contains one or more NSNull instances, it means that an error has
/// occurred in caching an object associated with one or more of the keys.
///
/// @returns A NSArray containing any untracked cached objects. If no untracked cached objects
/// exist, the array is empty.
- (NSArray* _Nonnull)untrackedObjects;


/// Returns all cached object keys.
///
/// @returns A NSArray containing any cached object keys. If no keys
/// exist, the array is empty.
- (NSArray* _Nonnull)allKeys;


/// Returns all tracked cached object keys.
///
/// @returns A NSArray containing any tracked cached object keys. If no keys
/// exist, the array is empty.
- (NSArray* _Nonnull)trackedKeys;


/// Returns all untracked cached object keys.
///
/// @returns A NSArray containing any untracked cached object keys. If no keys
/// exist, the array is empty.
- (NSArray* _Nonnull)untrackedKeys;


/// Returns all cached objects and their keys.
///
/// @returns A NSDictionary containing any cached objects associated with thier keys. If no objects
/// exist, the array is empty.
- (NSDictionary* _Nonnull)allObjectsAndKeys;


/// Returns all tracked cached objects and their keys.
///
/// @returns A NSDictionary containing any tracked cached objects associated with thier keys. If no objects
/// exist, the array is empty.
- (NSDictionary* _Nonnull)trackedObjectsAndKeys;


/// Returns all untracked cached objects and their keys.
///
/// @returns A NSDictionary containing any untracked cached objects associated with thier keys. If no objects
/// exist, the array is empty.
- (NSDictionary* _Nonnull)untrackedObjectsAndKeys;

@end


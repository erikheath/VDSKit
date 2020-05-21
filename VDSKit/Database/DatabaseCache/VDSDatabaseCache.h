//
//  VDSDatabaseCache.h
//  VDSKit
//
//  Created by Erikheath Thomas on 4/20/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

@import Foundation;

#import "VDSConstants.h"
#import "../ExtendedOperations/VDSOperationQueue.h"

@class VDSDatabaseCache;
@class VDSEvictionOperation;
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
@interface VDSDatabaseCache : NSObject <NSFastEnumeration, NSSecureCoding, VDSOperationQueueDelegate> {
    
}


#pragma mark Delegation

/// @summary A delegate object that conforms to VDSDatabaseCacheDelegate. Use the delegate to
/// control when/if evictions take place and which objects will be evicted.
///
@property(weak, readwrite, nullable) id<VDSDatabaseCacheDelegate> delegate;


#pragma mark Cache Configuration

/// @summary Determines whether the cache records an expiration date for an object that
/// is added to the cache via the addTrackedObject method. The default is NO.
///
/// Corresponds to the VDSExpiresObjectKey.
///
@property(readonly) BOOL expiresObjects;


/// @summary Indicates the preferred maximum number of objects the cache should hold.
/// This is a target amount, not a fixed ceiling. The cache will attempt to keep the number
/// of objects near this amount whenever possible while satifying other configuration
/// constraints.
///
/// @discussion Setting a value of 0 indicates there is no maximum. The default is 0.
/// Setting a value less than 0 indicates that the cache should evict objects as soon as possible. When setting
/// the value to less than 0, the cache will be set to expire objects and object usage will be tracked
/// to prevent the cache from prematurely evicting objects after they have been added.
///
/// Corresponds to the VDSPreferredMaxObjectCountKey.
///
@property(readonly) NSInteger preferredMaxObjectCount;


/// @summary Determines whether objects will be selected for eviction in LIFO (last in, first out)
/// or FIFO (first in, first out) order when being processed for eviction based on
/// cache size preferences. The default is VDSLIFOPolicy.
///
/// Corresponds to the VDSEvictionPolicyKey.
///
@property(readonly) VDSEvictionPolicy evictionPolicy;


/// @summary Determines whether the cache will dispatch an eviction operation when a low memory notification
/// is received. The default is NO.
///
/// Corresponds to the VDSEvictsOnLowMemoryKey.
///
@property(readonly) BOOL evictsOnLowMemory;


/// @summary Determines whether the cache tracks objects that are in use by setting up
/// a usage list.
///
/// @discussion When tracks Usage is enabled, added objects automatically receive
/// a usage count of one. When the object expires, that usage count is decremented
/// by one. If objects are not tracked for expiration, they must be removed using the
/// evictTrackedObject: method. The default is NO.
///
/// Corresponds to the VDSTracksObjectUsageKey.
///
@property(readonly) BOOL tracksObjectUsage;


/// @summary Determines whether the cache will evict objects that have a usage value of one (1)
/// or higher. The default is NO.
///
/// Corresponds to the VDSEvictsObjectsInUseKey.
///
@property(readonly) BOOL evictsObjectsInUse;


/// @summary Determines whether an object will be replaced or have its current values merged
/// with new values from an object added using the same key. The default is YES indicating that
/// objects will be replaced.
///
/// @discussion Merging is only supported for objects with KVC compliant properties and with
/// properties that are determinable using -(NSArray*)allKeys, -(id)keyEnumerator, or the Objective-C
/// runtime property inspection methods or that conform to VDSMergableObject protocol (preferred).
///
/// Conforming to the VDSMergableObject protocol enables implementors to have granular
/// control over what values are merged, replaced, or skipped. Objects that do not conform
/// to the protocol (but whose keys are determinable) will have their values replaced.
///
/// Corresponds to the VDSReplacesObjectsOnUpdateKey.
///
@property(readonly) BOOL replacesObjectsOnUpdate;


/// @summary The dispatch interval, in seconds, between eviction operations.
/// The default interval is 300 seconds.
///
/// Corresponds to the VDSEvictionIntervalKey.
///
@property(readonly) NSTimeInterval evictionInterval;


/// Determines whether the cache will archive untracked objects when encoding itself.
/// The default is NO.
///
/// Corresponds to the VDSArchivesUntrackedObjectsKey.
///
@property(readonly) BOOL archivesUntrackedObjects;


#pragma mark Object Lifecycle

/// @summary Creates a new database cache using the default configuration.
///
/// @discussion The default configuration consists of a cache that does not expire, track, or
/// evict objects, does not have a maximum size, and will not archive untracked objects.
///
/// @returns An instance of the cache using the default configuration.
///
- (instancetype _Nonnull)init;


/// @summary Creates a new database cache using the configuration specified by the keys
/// and values in the configuration dictionary. To create a cache with a default
/// configuration, use init.
///
/// @param configuration A dictionary with keys and values corresponding to the Cache
/// Configuration properties.
///
/// @returns An instance of the cache using the provided configuration.
///
- (instancetype _Nonnull)initWithConfiguration:(NSDictionary* _Nonnull)configuration NS_DESIGNATED_INITIALIZER;


#pragma mark Eviction Behaviors

/// @summary Immediately attempts to launch the eviction process on the eviction queue. This
/// method does not indicate that evictions were completed successfully, only that an eviction
/// operation has been created and accepted on the eviction queue.
///
/// @discussion Evictions are performed in a series cancellable operations: one for expired objects, one
/// for cache size maintainance, and one for usage. Subclasses can add eviction operations
/// or override the dependency chain to reorder, and therefore reprioritize how the eviction
/// process works. For more information, refer to the class documentation for
/// VDSEvictionOperation.
///
/// @param error An error object describing the error. Use the return value to know when
/// to check for an error object. A return value of NO will always produce an error object.
///
/// @returns YES if the eviction operation was created and accepted by the eviction queue, NO otherwise.
///
- (BOOL)processEvictions:(NSError* __autoreleasing _Nullable * _Nullable)error;


/// @summary Attempts to evict an object from the cache, eviction policy list and expiration list when
/// in use by the cache, triggering delegate methods and notifications as needed.
///
/// @discussion This method attempts to evict an object following the rules set by the
/// cache configuration. To forcibly remove an object from the cache, use removeObjectForKey:.
///
/// @param key The unique identifier used to store the object in the cache.
///
/// @param error An error object describing the error. Use the return value to know when
/// to check for an error object. A return value of NO will always produce an error object.
///
/// @returns YES if the object was evicted successfully, NO otherwise.
///
- (BOOL)evictObject:(id _Nonnull)key
              error:(NSError* __autoreleasing _Nullable * _Nullable)error;


#pragma mark Usage Count Behaviors

/// @summary Increments the usage counter for the object associated with the key.
///
/// @param key The unique identifier used to store the object in the cache.
///
/// @param error An error object describing the error. Use the return value to know when
/// to check for an error object. A return value of NO will always produce an error object.
///
/// @returns YES if the usage counter was incremented successfully, NO otherwise.
///
- (BOOL)incrementUsageCount:(id _Nonnull)key
                      error:(NSError* __autoreleasing _Nullable * _Nullable)error;


/// Decrements the usage counter for the object associated with the key.
///
/// @param key The unique identifier used to store the object in the cache.
///
/// @param error An error object describing the error. Use the return value to know when
/// to check for an error object. A return value of NO will always produce an error object.
///
/// @returns YES if the usage counter was decremented successfully, NO otherwise.
///
- (BOOL)decrementUsageCount:(id _Nonnull)key
                      error:(NSError* __autoreleasing _Nullable * _Nullable)error;


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
/// @returns A NSArray containing any tracked cached objects. If no tracked cached objects
/// exist, the array is empty.
- (NSArray* _Nonnull)trackedObjects;


/// Returns all untracked cached objects.
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


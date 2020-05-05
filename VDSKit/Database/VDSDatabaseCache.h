//
//  VDSDatabaseCache.h
//  VDSKit
//
//  Created by Erikheath Thomas on 4/20/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDSConstants.h"

@class VDSDatabaseCache;
@class VDSEvictionOperation;

#pragma mark - VDSDatabaseCacheDelegate -


/// Objects that conform to the VDSDatabaseCacheDelegate protocol can receive messages
/// from a VDSDatabaseCache when the cache engages in its eviction processing.
///
@protocol VDSDatabaseCacheDelegate <NSObject>

@optional

/// Allows the delegate to force the cache to skip the current scheduled eviction cycle.
/// @returns Return YES to allow the cycle to proceed, NO to force the cache to skip the eviction cycle.
- (BOOL)databaseCacheShouldBeginEvictionCycle;


/// Notifies the delegate that an eviction cycle of type 'cycleKey' is about to begin.
/// @param cache The database cache that will be evicting objects.
/// @param cycleKey The type of eviction cycle that will be used to evict objects.
- (void)databaseCache:(VDSDatabaseCache* _Nonnull)cache
    willBeginEvictionCycle:(VDSEvictionCycleKey _Nonnull)cycleKey;


/// Notifies the delegate that the eviction cycle of type 'cycleKey' has completed.
/// @param cache The database cache that evicted objects
/// @param cycleKey The type of eviction cycle that was used to evict objects.
- (void)databaseCache:(VDSDatabaseCache* _Nonnull)cache
    didCompleteEvictionCycle:(VDSEvictionCycleKey _Nonnull)cycleKey;


/// Allows the delegate to determine if a specific object should be evicted from the database cache.
/// @param cache The database cache that will be evicting objects.
/// @param object The object from the database cache that will be evicted.
/// @param cacheKey The used by the database cache to store the object.
/// @param cycleKey The type of eviction cycle that is being used to evict the object.
- (BOOL)databaseCache:(VDSDatabaseCache* _Nonnull)cache
    shouldEvictObject:(id _Nonnull)object
             usingKey:(id _Nonnull)cacheKey
      inEvictionCycle:(VDSEvictionCycleKey _Nonnull)cycleKey;


/// Notifies the delegate that a set of objects will be evicted from the database cache.
/// @param cache The database cache that will be evicting objects.
/// @param objects The objects from the database cache that will be evicted.
/// @param cacheKeys The keys used by the database cache to store the objects.
/// @param cycleKey The type of eviction cycle that is being used to evict the objects.
- (void)databaseCache:(VDSDatabaseCache* _Nonnull)cache
     willEvictObjects:(NSArray* _Nonnull)objects
            usingKeys:(NSArray* _Nonnull)cacheKeys
      inEvictionCycle:(VDSEvictionCycleKey _Nonnull)cycleKey;


/// Notifies the delegate that a set of objects was evicted from the datbase cache.
/// @param cache The database cache that evicted the objects.
/// @param objects The objects that were evicted from the database cache.
/// @param cacheKeys The keys used by the database cache to store the evicted objects.
/// @param cycleKey The type of eviction cycle that is being used to evict the objects.
- (void)databaseCache:(VDSDatabaseCache* _Nonnull)cache
      didEvictObjects:(NSArray* _Nonnull)objects
            usingKeys:(NSArray* _Nonnull)cacheKeys
      inEvictionCycle:(VDSEvictionCycleKey _Nonnull)cycleKey;


@end


#pragma mark - VDSExpirableObject -


/// A VDSExpirableObject associates a an expiration date with an object. Typically
/// this is used as a convenient way to track and order objects for time-based
/// processing.
///
/// @discussion For example, the VDSDatabaseCache uses expirable objects in a
/// time sorted list to quickly determine which of its cached objects have expired
/// and therefore are no longer valid when requested.
///
/// VDSExpirableObject overrides its hash method to enable searching for the
/// object stored in its object property.
///
/// @note VDSExpirableObject does not support archiving as it would not make
/// much sense to archive an object that would expire while stored.
///
@interface VDSExpirableObject : NSObject

/// The date used to indicate when an associated object should expire.
@property(strong, readonly, nonnull, nonatomic) NSDate* expiration;

/// An object whose lifespan is associated with the expiration date.
@property(strong, readonly, nonnull, nonatomic) id object;

/// Creates a VDSExpirableObject that associates a expiration date with
/// an object. Passing a nil expiration or object values will cause
/// initialization to fail.
/// @param expiration The date that associated object is set to expire.
/// @param object An object whose lifespan is associated with the expiration date.
/// @param error An error object describing the error. Use the return value to know when
/// to check for an error object. A return value of nil will always produce an error object.
///
/// @returns An instance of VDSExpirableObject if successful, otherwise nil.
- (instancetype _Nullable )initWithExpiration:(NSDate* _Nonnull)expiration
                                       object:(id _Nonnull)object
                                        error:(NSError* __autoreleasing _Nonnull * _Nonnull)error;
@end


#pragma mark - VDSEvictionOperation -


@interface VDSEvictionOperation : NSOperation

@end


#pragma mark - VDSDatabaseCache -



/// @summary VDSDatabaseCache provides a subclassable, enumerable, and archivable object caching system.
/// The class provides object tracking using expiration, usage, and/or max object counts and supports
/// mixing of tracked and untracked objects for maximum caching flexibility. Adding and evicting methods
/// are thread safe, as are all cache configuration properties. The class may be used as is, may be
/// safely subclassed, or may be used as a backing class for a fascade that limits direct cache storage
/// manipulation to fascade internals.
///
/// @discussion VDSDatabaseCache supports fast enumeration over the contents contained in its cachedObjects
/// property. To enumerate only those items that are tracked, obtain the keys from the evictionPolicyKeyList
/// and use them to enumerate the tracked objects contained in the cache.
///
/// To enumerate over the items that are not tracked, create a mutable set of keys from the cachedObjects
/// dictionary, a set from the evictionPolicyKeyList, and take the difference between the two sets. The
/// resulting set will be all of the keys that correspond to the untracked objects.
///
/// The cache also supports archiving of untracked objects when archivesUntrackedObjects is set to YES. To
/// archive tracked objects, create a subclass of VDSDatabaseCache and override initWithCoder: and
/// encodeWithCoder:, calling the super class methods to encode the configuration (and untracked objects
/// if desired). Use the evictionPolicyKeyList to iterate and create a new dictionary of only the tracked
/// objects that can be encoded and decoded, or use the previously mentioned untracked objects enumeration
/// method to create a set of untracked object keys, converting it to an array and then using it as the input
/// to the removeObjectsForKeys: method on a mutable copy of the cachedObjects dictionary. The result of
/// either technique is a mutable dictionary that can be encoded. When decoding in the init method, make sure
/// to use the addTrackedObject method to add the objects to the cachedObjects mutable dictionary. Otherwise
/// the objects will become untracked.
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

#pragma mark Cache Storage

/// The main storage for the cache. Objects are store using a globally unique (for the cache) key
/// that is used throughout the cache tracking system to refer to the object.
///
/// @discussion It is possible to add cache objects directly without using the tracking system,
/// mixing both tracked and untracked objects. This use case is desirable when some objects should be
/// tracked for removal, while other objects should effectively be persistent (at least for the life
/// of the cache). This design can be more desirable, and simpler than constructing expressions to set
/// expiration dates far into the future for a subset of objects in the cache. This also allows you to
/// ignore usage rules for certain objects.
///
/// Typical uses of untracked objects include permanent or semi-permanent lookup tables (e.g. zip codes,
/// state abbreviations, flight numbers, etc.), data loaded from local sources, or reference data for tracked
/// objects that should only be evicted when the tracked object is evicted.
@property(strong, readonly, nonnull) NSMutableDictionary* cacheObjects;

#pragma mark Cache Tracking

/// Maintains a list, in temporal order, of expirable objects. An expirable object
/// cotains a timestamp representing when an object in the cache should expire and
/// the object's associated key. Setting expiresObjects to YES will initialize the
/// expirationTable, otherwise the default value is nil.
@property(strong, readonly, nullable) NSMutableArray<VDSExpirableObject*>* expirationTable;

/// Maintains a list of keys for objects in the cache and each object's number of uses.
/// Setting tracksObjectUsage to YES will initialize the usageList, otherwise the default
/// value is nil.
@property(strong, readonly, nullable) NSCountedSet* usageList;

/// Maintains a list of keys for objects in the cache in the order in which they were added.
/// The most recent addition is at the highest index and the oldest addition is at index 0.
@property(strong, readonly, nonnull) NSMutableArray* evictionPolicyKeyList;

/// @summary An expression that must evaluate to one of the keys used in the expirationTimingMap.
/// The expression is evaluated against an incoming key and with a NSMutableDictionary as
/// a context object that contains a the incoming object associated with VDSEntrySnapshotKey.
/// Setting expiresObjects to YES will initialize the expirationTable, otherwise the default value is nil.
@property(strong, readonly, nullable) NSExpression* expirationTimingMapKey;

/// @summary A map of expressions that evaluate to an expriation date for incoming objects
/// with keys that must be determinable using the expirationTimingMapKey expression. Each
/// expression is evaluated against an incoming key and with a NSMutableDictionary as
/// a context object that contains a the incoming object associated with VDSEntrySnapshotKey.
/// Setting expiresObjects to YES will initialize the expirationTable, otherwise the default value is nil.
@property(strong, readonly, nullable) NSDictionary<id, NSExpression*>* expirationTimingMap;

/// @summary A dispatch queue used to coordinate cache tracking reads and writes. Subclasses should
/// use the syncQueue and/or lock objects, barriers, etc. to create fascades that ensure reading of
/// and writing to the cache is thread safe.
@property(strong, readonly, nonnull) dispatch_queue_t syncQueue;

/// @summary A recursive lock used to coordinate cache tracking reads and writes. Subclasses should
/// use the coordinatorLock, synchQueue, barriers, etc. to create fascades that ensure reading of
/// and writing to the cache is thread safe.
@property(strong, readonly, nonnull) NSRecursiveLock* coordinatorLock;

/// @summary An timer used as a repeating loop to add eviction operations to the evictionQueue.
/// If the queue is suspended when the timer fires, the eviction loop timer will skip
/// adding an eviction operation to the queue but will continue to check the queue
/// at its designated intervals. Once the timer determines the queue has been unsuspended,
/// it will wait until a subsequent loop to add an eviction operation to the eviction queue.
@property(strong, readonly, nonnull) NSTimer* evictionLoop;

/// @summary The operation queue used by the cache to process eviction operations against its
/// cached objects. The queue may be suspended and /or its operations canceled to
/// prevent or pause evictions as needed.
@property(strong, readonly, nonnull) NSOperationQueue* evictionQueue;

/// @summary The eviction operation used by the cache to process object evictions. Use the
/// VDSCacheEvictionOperationClassNameKey when initializing the class in the metadata
/// dictionary to specify a subclass of VDSEvictionOperation.
@property(strong, readonly, nonnull) VDSEvictionOperation* evictionOperation;


#pragma mark Delegation

/// @summary A delegate object that conforms to VDSDatabaseCacheDelegate. Use the delegate to
/// control when/if evictions take place and which objects will be evicted.
@property(weak, readwrite, nullable) id<VDSDatabaseCacheDelegate> delegate;


#pragma mark Cache Configuration

/// @summary Determines whether the cache records an expiration date for an object that
/// is added to the cache via the addTrackedObject method. The default is NO.
@property(readonly) BOOL expiresObjects;

/// @summary Indicates the preferred maximum number of objects the cache should hold.
/// This is a target amount, not a fixed ceiling. The cache will attempt to keep the number
/// of objects near this amount whenever possible while satifying other configuration
/// constraints.
/// @discussion Setting a value of 0 indicates there is no maximum. The default is 0.
///
/// Setting a value
/// less than 0 indicates that the cache should evict objects as soon as possible. When setting
/// the value to less than 0, the cache must be set to expire objects and object usage must be tracked
/// to prevent the cache from prematurely evicting objects after they have been added.
@property(readonly) NSInteger preferredMaxObjectCount;

/// @summary Determines whether objects will be selected for eviction in LIFO (last in, first out)
/// or FIFO (first in, first out) order when being processed for eviction based on
/// cache size preferences. The default is VDSLIFOPolicy.
@property(readonly) VDSEvictionPolicy evictionPolicy;

/// @summary Determines whether the cache will dispatch an eviction operation when a low memory notification
/// is received. The default is NO.
@property(readonly) BOOL evictsOnLowMemory;

/// @summary Determines whether the cache tracks objects that are in use by setting up
/// a usage list. When tracks Usage is enabled, added objects automatically receive
/// a usage count of one. When the object expires, that usage count is decremented
/// by one. If objects are not tracked for expiration, they must be removed using the
/// evictTrackedObject: method. The default is NO.
@property(readonly) BOOL tracksObjectUsage;

/// @summary Determines whether the cache will evict objects that have a usage value of one (1)
/// or higher. The default is NO.
@property(readonly) BOOL doesNotEvictObjectsInUse;

/// @summary Determines whether an object will be replaced or have its current values merged
/// with new values from an object added using the same key. The default is YES.
@property(readonly) BOOL replacesObjectsOnUpdate;

/// @summary The dispatch interval, in seconds, between eviction operations. The default interval is 300 seconds.
@property(readonly) NSTimeInterval evictionInterval;

/// Determines whether the cache will archive untracked objects when encoding itself. The default is NO.
@property(readonly) BOOL archivesUntrackedObjects;

#pragma mark Main Public Behaviors


/// @summary Creates a new database cache using the configuration specified by the keys
/// and values in the configuration dictionary. To create a cache with a default
///  configuration, use init.
///
/// @param configuration A dictionary with keys and values corresponding to the Cache
/// Configuration properties.
/// @param error An error object describing the error. Use the return value to know when
/// to check for an error object. A return value of nil will always produce an error object.
///
/// @returns An instance of the cache if successful, otherwise nil.
- (instancetype _Nullable)initWithConfiguration:(NSDictionary* _Nonnull)configuration
                                          error:(NSError* __autoreleasing _Nullable * _Nullable)error;


/// @summary Immediately attempts to launch the eviction process on the eviction queue. This
/// method does not indicate that evictions were completed successfully, only that an eviction
/// operation has been dispatched on the queue.
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
/// @returns YES if the eviction process was dispatched on the eviction queue, NO otherwise.
- (BOOL)processEvictions:(NSError* __autoreleasing _Nullable * _Nullable)error;


/// @summary Evicts an object from the cache, eviction policy list and expiration list when
/// respectively in use by the cache. Triggers delegate methods, notifications.
///
/// @param key The unique global identifier used to store the object in the cache.
/// @param error An error object describing the error. Use the return value to know when
/// to check for an error object. A return value of NO will always produce an error object.
///
/// @returns YES if the object was evicted successfully, NO otherwise.
- (BOOL)evictTrackedObject:(id _Nonnull)key
                     error:(NSError* __autoreleasing _Nullable * _Nullable)error;


/// @summary Adds an object to the cache and optionally tracks and if necessary evicts
/// the object according to the cache configuration.
///
/// @param object A nonnull object to be tracked by the cache.
/// @param key A nonnull globally unique key that should be associated with the object
/// being tracked. If the key already exists in the cache, the new object is treated as
/// an update and the values of the new object are either merged or replaced by the
/// new object according to the cache configuration.
///
/// @returns YES if the object was added successfully, NO otherwise.
- (BOOL)addTrackedObject:(id _Nonnull)object
                usingKey:(id _Nonnull)key;


/// @summary Increments the usage counter for the object associated with the key.
///
/// @param key The unique global identifier used to store the object in the cache.
/// @param error An error object describing the error. Use the return value to know when
/// to check for an error object. A return value of NO will always produce an error object.
///
/// @returns YES if the usage counter was incremented successfully, NO otherwise.
- (BOOL)incrementUsageCount:(id _Nonnull)key
                      error:(NSError* __autoreleasing _Nullable * _Nullable)error;


/// Decrements the usage counter for the object associated with the key.
/// @param key The unique global identifier used to store the object in the cache.
/// @param error An error object describing the error. Use the return value to know when
/// to check for an error object. A return value of NO will always produce an error object.
///
/// @returns YES if the usage counter was decremented successfully, NO otherwise.
- (BOOL)decrementUsageCount:(id _Nonnull)key
                      error:(NSError* __autoreleasing _Nullable * _Nullable)error;


@end


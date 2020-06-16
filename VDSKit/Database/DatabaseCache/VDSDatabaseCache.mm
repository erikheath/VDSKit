//
//  VDSCache.m
//  VDSKit
//
//  Created by Erikheath Thomas on 4/20/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import "VDSDatabaseCache.h"
#import "../../VDSConstants.h"
#import "../../VDSErrorConstants.h"
#import "VDSExpirableObject.h"
#import "VDSDatabaseCacheConfiguration.h"
#import "VDSMergeableObject.h"
#import "objc/runtime.h"

#include <list>





#pragma mark - VDSDatabaseCache Extension -

@interface VDSDatabaseCache () {
    
    /// Object Access Time List, used to determine the recency of access of a cached object.
    ///
    std::list<id>* _oatList;
    
    /// Maintains a list, in temporal order, of expirable objects. An expirable object
    /// cotains a timestamp representing when an object in the cache should expire and
    /// the object's associated key. Setting expiresObjects to YES will initialize the
    /// expireList, otherwise the default value is NULL.
    ///
    std::list<void*>* _expireList;
    
}



#pragma mark Cache Storage


/// The main storage for the cache. Objects are stored using a unique (for the cache) key
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
///
@property(strong, readonly, nonnull) NSMutableDictionary* cacheObjects;



#pragma mark Cache Tracking

/// Maintains a list of keys for objects in the cache and each object's number of uses.
/// Setting tracksObjectUsage to YES will initialize the usageList, otherwise the default
/// value is nil.
///
@property(strong, readonly, nullable) NSCountedSet* usageList;


/// Maintains a list of keys and iterators for objects in the _oatList for rapid reference.
/// Use the key to access the iterator for the _oatList (oldest access time list).
///
@property(strong, readonly, nonnull) NSMapTable* evictionPolicyKeyMap;


/// @summary An expression that must evaluate to one of the keys used in the expirationTimingMap.
/// The expression is evaluated against an incoming key and with a NSMutableDictionary as
/// a context object that contains the incoming object associated with VDSEntrySnapshotKey.
/// Setting expiresObjects to YES will initialize the expirationTable, otherwise the default value is nil.
///
@property(strong, readonly, nullable) NSExpression* expirationTimingMapKey;


/// @summary A map of expressions that evaluate to an expriation date for incoming objects
/// with keys that must be determinable using the expirationTimingMapKey expression. Each
/// expression is evaluated against an incoming key and with a NSMutableDictionary as
/// a context object that contains a the incoming object associated with VDSEntrySnapshotKey.
/// Setting expiresObjects to YES will initialize the expirationTable, otherwise the default value is nil.
///
@property(strong, readonly, nullable) NSDictionary<id, NSExpression*>* expirationTimingMap;


/// Maintains a list of keys and iterators of objects in the _expireList O(1) reference.
/// Use the key to access the iterator.
///
@property(strong, readonly, nullable) NSMapTable* expirationMap;


/// @summary A recursive lock used to coordinate cache tracking reads and writes. Subclasses should
/// use the coordinatorLock, synchQueue, barriers, etc. to create facades that ensure reading of
/// and writing to the cache is thread safe.
///
@property(strong, readonly, nonnull) NSRecursiveLock* coordinatorLock;


/// @summary An timer used as a repeating loop to add eviction operations to the evictionQueue.
/// If the queue is suspended when the timer fires, the eviction loop timer will skip
/// adding an eviction operation to the queue but will continue to check the queue
/// at its designated intervals. Once the timer determines the queue has been unsuspended,
/// it will wait until a subsequent loop to add an eviction operation to the eviction queue.
///
@property(strong, readonly, nonnull) NSTimer* evictionLoop;


/// Maintains a time marker for the last time value marked for eviction by the cache eviction cycle.
@property(strong, readwrite, nullable) NSDate* priorEvictionTime;


@end





#pragma mark - VDSDatabaseCache -

@implementation VDSDatabaseCache



#pragma mark Properties

@synthesize configuration = _configuration;
@synthesize defaultExpirationInterval = _defaultExpirationInterval;

@synthesize cacheObjects = _cacheObjects;
@synthesize usageList = _usageList;
@synthesize evictionPolicyKeyMap = _evictionPolicyKeyMap;
@synthesize expirationTimingMapKey = _expirationTimingMapKey;
@synthesize expirationTimingMap = _expirationTimingMap;
@synthesize expirationMap = _expirationMap;
@synthesize coordinatorLock = _coordinatorLock;
@synthesize evictionLoop = _evictionLoop;
@synthesize priorEvictionTime = _priorEvictionTime;


+(BOOL)supportsSecureCoding { return YES; }



#pragma mark Object Lifecycle

- (instancetype _Nonnull)init
{
    return [self initWithConfiguration:[[VDSDatabaseCacheConfiguration alloc] init]];
}


- (instancetype _Nonnull)initWithConfiguration:(VDSDatabaseCacheConfiguration* _Nullable)configuration
{
    self = [super init];
    if (self != nil) {
        _expireList = NULL;
        _oatList = NULL;
        _configuration = [configuration copy];
        _cacheObjects = [NSMutableDictionary new];
        _coordinatorLock = [NSRecursiveLock new];
        if (_configuration.expiresObjects) {
            [self configureExpirationSystem];
            [self configureEvictionSystem];
            if (_configuration.tracksObjectUsage) { [self configureObjectTrackingSystem]; }
            [[NSRunLoop mainRunLoop] addTimer:_evictionLoop forMode:NSDefaultRunLoopMode];
        }
    }
    return self;
}


- (void)configureEvictionSystem
{
    _evictionPolicyKeyMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory | NSMapTableObjectPointerPersonality valueOptions:NSPointerFunctionsOpaqueMemory | NSPointerFunctionsStructPersonality];
    _oatList = new std::list<id>;
    _evictionLoop = [NSTimer timerWithTimeInterval:_configuration.evictionInterval
                                            target:self
                                          selector:@selector(processEvictions:)
                                          userInfo:nil
                                           repeats:YES];
    _priorEvictionTime = [NSDate distantPast];
}


- (void)configureObjectTrackingSystem
{
    _usageList = _configuration.tracksObjectUsage ? [NSCountedSet new] : nil;
}


- (void)configureExpirationSystem
{
    _expirationMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory | NSMapTableObjectPointerPersonality valueOptions:NSPointerFunctionsOpaqueMemory | NSPointerFunctionsStructPersonality];
    _expireList = new std::list<void*>;
    _expirationTimingMap = [_configuration.expirationTimingMap copy];
    _expirationTimingMapKey = [_configuration.expirationTimingMapKey copy];
}


- (void)dealloc {
    /// Removing all objects cleans up all ARC transfers.
    [self removeAllObjects];
    
    delete _oatList;
    delete _expireList;
}



#pragma mark Coder Support

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder
{
    VDSDatabaseCacheConfiguration* configuration = [coder decodeObjectOfClass:[VDSDatabaseCacheConfiguration class] forKey:NSStringFromSelector(@selector(configuration))];
    self = [self initWithConfiguration:configuration];
    NSDictionary* untrackedObjectsAndKeys = [coder decodeObjectOfClass:[NSDictionary class]
                                                                forKey:NSStringFromSelector(@selector(untrackedObjectsAndKeys))];
    if (untrackedObjectsAndKeys) {
        [_cacheObjects addEntriesFromDictionary:untrackedObjectsAndKeys];
    }
    return self;
}


- (void)encodeWithCoder:(nonnull NSCoder *)coder
{
    [coder encodeObject:_configuration forKey:NSStringFromSelector(@selector(configuration))];
    if (_configuration.archivesUntrackedObjects) {
        [coder encodeObject:[self untrackedObjectsAndKeys] forKey:NSStringFromSelector(@selector(untrackedObjectsAndKeys))];
    }
}



#pragma mark - Utility Behaviors

/// Used as the comparator for _expireList sorting.
///
/// @param first An expirable object.
///
/// @param second The expirable object used in the comparison.
///
/// @returns True if second should come after first, false otherwise.
///
bool compare_expirations (const void* first, const void* second)
{
    VDSExpirableObject* fexp = (__bridge VDSExpirableObject*)first;
    VDSExpirableObject* sexp = (__bridge VDSExpirableObject*)second;
    if ([fexp.expiration compare:sexp.expiration] == NSOrderedDescending) {
        return true;
    }
    return false;
}



#pragma mark - Eviction Behaviors

- (void)processEvictions:(NSTimer* _Nonnull)timer
{
    /// Launches the eviction operation unless one exists on the queue.
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        [self processCacheEvictions];
    });
}


- (void)processCacheEvictions
{
    [_coordinatorLock lock];

    ///
    /// The cache takes an aggressive approach, removing objects that are
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
    
    /// expiredKeys is used as a bin that can be enumerated without mutation when removing items.
    NSMutableArray* expiredKeys = [NSMutableArray new];
    /// removableKeys is used as a bin for keys that can be removed but do not have to be if space
    /// permits.
    NSMutableArray* removableKeys = [NSMutableArray new];
    
    /// This is the only time expired keys are sorted.
    if (_expireList != NULL) {
        _expireList->sort(compare_expirations);
    }
    
    /// Step 1. Update the usage count for tracked objects if appropriate.
    if (_configuration.expiresObjects) {
        std::list<void*>::reverse_iterator iter;
        for (iter = _expireList->rbegin(); iter != _expireList->rend(); ++iter) {
            VDSExpirableObject* object = (__bridge VDSExpirableObject*)(*iter);
            if (object.isExpired &&
                ([object.expiration compare:_priorEvictionTime] == NSOrderedAscending ||
                 [object.expiration compare:_priorEvictionTime] == NSOrderedSame)) {
                /// This is the first eviction cycle where the object is expired. Decrement its usage count
                /// to account for initial use increment when the object was added to the object cache.
                if (_configuration.tracksObjectUsage) {
                    [self decrementUsageCount:object.object];
                    if ([_usageList countForObject:object.object] == 0) {
                        [expiredKeys addObject:object.object];
                    } else if (_configuration.evictsObjectsInUse) {
                        [removableKeys addObject:object.object];
                    }
                } else {
                    [expiredKeys addObject:object.object];
                }
            } else if (object.isExpired == NO) {
                /// This will be the first object in the ordered array that is not expired in the current
                /// eviction cycle. It's date will be used to set the priorEvictionTime and the loop
                /// will be broken to continue the eviction process.
                _priorEvictionTime = object.expiration;
                break;
            }
        }
    }
    
    /// Step 2. Remove Objects that are expired and unused.
    for (id key in expiredKeys) {
        [self removeObjectForKey:key];
    }
    
    /// Step 3. If the cache exceeds the preferred max object count, remove objects
    /// using the removableKeys array. In this implementation, it's an all or nothing affair.
    if (_configuration.preferredMaxObjectCount < _expireList->size()) {
        for (id key in removableKeys) {
            [self removeObjectForKey:key];
        }
    }
    
    /// Step 4. If the cache still exceeds the preferred max object count, remove in LIFO, FIFO, or OAT
    /// order all unused objects until the cache meets the preferred max object count. In the cache,
    /// unused objects that have not expried have a usage count of 1. At this point, no cache object
    /// that is unexpired will have a usage count of 1 unless it is not being used.
    if (_configuration.preferredMaxObjectCount < _expireList->size()) {
        if (_configuration.evictionPolicy == VDSFIFOPolicy) {
            for (std::list<id>::iterator iter = _oatList->begin(); iter!=_oatList->end(); ++iter) {
                id key = *iter;
                /// If the object is before the priorEvictionTime, it is in use and should be skipped.
                std::list<id>::iterator iterator = *((std::list<id>::iterator*)NSMapGet(_expirationMap, (__bridge void *)key));
                if ([((NSDate*)*iterator) compare:_priorEvictionTime] == NSOrderedDescending) { continue; }
                /// If the object has a usage count of 1, it should be removed until we hit preferred
                /// max object count.
                if ([_usageList countForObject:key] == 1) { [self removeObjectForKey:key]; }
                /// When the count is at the object count, break to stop removing objects.
                if (_configuration.preferredMaxObjectCount == _expireList->size()) {
                    break;
                }
            }
        } else {
            for (std::list<id>::reverse_iterator iter = _oatList->rbegin(); iter!=_oatList->rend(); ++iter) {
                id key = *iter;
                /// If the object is before the priorEvictionTime, it is in use and should be skipped.
                std::list<id>::iterator iterator = *((std::list<id>::iterator*)NSMapGet(_expirationMap, (__bridge void *)key));
                if ([((VDSExpirableObject*)*iterator).expiration compare:_priorEvictionTime] == NSOrderedDescending) { continue; }
                /// If the object has a usage count of 1, it should be removed until we hit preferred
                /// max object count.
                if ([_usageList countForObject:key] == 1) { [self removeObjectForKey:key]; }
                /// When the count is at the object count, break to stop removing objects.
                if (_configuration.preferredMaxObjectCount == _expireList->size()) {
                    break;
                }
            }
        }
    }
    
    [_coordinatorLock unlock];
}


- (BOOL)incrementUsageCount:(id _Nonnull)key
{
    BOOL success = NO;
    /// You can not increment the usage count of a key that
    /// is not already in the usage list.
    [_coordinatorLock lock];
    if ([_usageList countForObject:key] > 0) {
        [_usageList addObject:key];
        success = YES;
        /// If the tracking is OAT, then the access time
        /// needs to be updated.
        if (_configuration.evictionPolicy == VDSOATPolicy) {
            [self updatedAccessTimeForKey:key];
        }
    }
    [_coordinatorLock unlock];
    return success;
}


- (BOOL)decrementUsageCount:(id _Nonnull)key
{
    BOOL success = NO;
    /// You can not decrement the usage count of a key that
    /// is not already in the usage list.
    [_coordinatorLock lock];
    if ([_usageList countForObject:key] > 0) {
        [_usageList removeObject:key];
        success = YES;
    }
    [_coordinatorLock unlock];
    return success;
}



#pragma mark - Supporting Behaviors

- (void)setObject:(id _Nonnull)object forKey:(id _Nonnull)key
{
    [_coordinatorLock lock];
    [self setObject:object forKey:key tracked:NO expires:nil];
    [_coordinatorLock unlock];
}


-(void)setObject:(id)object forKey:(id)key tracked:(BOOL)tracked
{
    [_coordinatorLock lock];
    [self setObject:object forKey:key tracked:tracked expires:nil];
    [_coordinatorLock unlock];
}


- (void)setObject:(id _Nonnull)object
           forKey:(id _Nonnull)key
          tracked:(BOOL)tracked
          expires:(NSDate * _Nullable)expiration
{
    /// When setting an object, its important to lock down the various parts of the
    /// cache that support the state of the object as the change needs to be 'atomic'.
    [_coordinatorLock lock];
    
    /// If the object contained in the cache is mergable, then the object
    /// needs to be extracted, merged, and then reset. If the object is
    /// not mergable, then it needs to be replaced.
    id cachedObject = [_cacheObjects objectForKey:key];
    if (cachedObject != nil &&
        _configuration.replacesObjectsOnUpdate == NO &&
        [object conformsToProtocol:@protocol(VDSMergeableObject)] &&
        [cachedObject conformsToProtocol:@protocol(VDSMergeableObject)]) {
        id mergableObject = (id<VDSMergableObject>)object;
        for (id key in [mergableObject mergeableKeys]) {
            id value = [mergableObject valueForKey:key];
            [cachedObject mergeValue:value forKey:key];
        }
    } else {
        [_cacheObjects setObject:object forKey:key];
    }
    
    if (_configuration.expiresObjects) {
        /// To keep the eviction policy list (FIFO, LIFO, or OAT/LRU) accurate,
        /// it's necessary to remove the prior instance of the key
        /// that was added to the list before adding the new entry.
        if (cachedObject != nil) { [self updatedAccessTimeForKey:key]; }
    
        /// If expiration is supported, the timing must be calculated (even if it's just
        /// read in from a value in object or key). As with the  eviction policy list,
        /// the expirable object must be removed and a new one created. Expirable object
        /// overrides hash so that equality (and therefore searching) is a function of the
        /// object value in expirable, not the timestamp which is used as a sorting key to
        /// speed up eviction.
        [self updateExpirationForKey:key expiration:expiration];
    
        /// Usage Tracking
        if (_configuration.tracksObjectUsage) { [_usageList addObject:key]; }
    }
    /// Once all of the changes have been made, unlock the coordinator.
    [_coordinatorLock unlock];
}


/// Utility method for insertion to keep the eviction list in the correct order.
///
/// @param key The key used to retrieve and set the eviction policy key map objects.
///
- (void)updatedAccessTimeForKey:(id)key
{
    /// To keep the eviction policy list (FIFO, LIFO, or OAT/LRU) accurate,
    /// it's necessary to remove the prior instance of the key
    /// that was added to the list before adding the new entry.
    std::list<id>::iterator* iterPointer = (( std::list<id>::iterator*)NSMapGet(_evictionPolicyKeyMap, (__bridge void*)key));
    if (iterPointer != NULL) { _oatList->erase(*iterPointer); }
    _oatList->push_front(key);
    auto iter = _oatList->begin();
    NSMapInsert(_evictionPolicyKeyMap, (__bridge void*)key, &iter);
}


/// Utility method for insertion to keep the expiration list updated.
///
/// @param key The key used to retrieve and set the expiration list objects.
///
/// @param expiration An optional expiration date.
///
- (void)updateExpirationForKey:(id _Nonnull)key
                    expiration:(NSDate* _Nullable)expiration
{
    /// If expiration is supported, the timing must be calculated (even if it's just
    /// read in from a value in object or key). As with the  eviction policy list,
    /// the expirable object must be removed and a new one created. Expirable object
    /// overrides hash so that equality (and therefore searching) is a function of the
    /// object value in expirable, not the timestamp which is used as a sorting key to
    /// speed up eviction.
    std::list<void*>::iterator* iterP = ((std::list<void*>::iterator*)NSMapGet(_expirationMap, (__bridge void*)key));
    if (iterP != NULL) {
        VDSExpirableObject* object = (__bridge_transfer VDSExpirableObject*)(**iterP);
        object = nil;
        _expireList->erase(*iterP);
        NSMapRemove(_expirationMap, (__bridge void*)key);
    }

    
    /// Determine the expiration.
    NSDate* expires = nil;
    
    /// If an expiration is provided as a parameter, that overrides all other options.
    if (expiration != nil) {
        expires = expiration;
    } else if (_expirationTimingMapKey != nil && _expirationTimingMap != nil) {
        id timingKey = [_expirationTimingMapKey expressionValueWithObject:key
                                                                  context:[NSMutableDictionary dictionaryWithObject:[_cacheObjects objectForKey:key] forKey:VDSEntrySnapshotKey]];
        expires = [_expirationTimingMap[timingKey] expressionValueWithObject:key
                                                                     context:[NSMutableDictionary dictionaryWithObject:[_cacheObjects objectForKey:key] forKey:VDSEntrySnapshotKey]];
    } else {
        expires = [NSDate dateWithTimeIntervalSinceNow:self.defaultExpirationInterval];
    }
    
    _expireList->push_front((__bridge_retained void*)[[VDSExpirableObject alloc] initWithExpiration:expires object:key]);
    
}


- (void)removeObjectForKey:(id _Nonnull)key
{
    /// Removal mechanics depends on whether an object is tracked.
    [_coordinatorLock lock];
    if (_configuration.expiresObjects) {
        std::list<id>::iterator* iterPointer = (std::list<id>::iterator*)NSMapGet(_evictionPolicyKeyMap, (__bridge void*)key);
        if (iterPointer != NULL) {
            NSMapRemove(_evictionPolicyKeyMap, (__bridge void*)key);
            _oatList->erase(*iterPointer);
        }
        
        std::list<void*>::iterator* iterP = ((std::list<void*>::iterator*)NSMapGet(_expirationMap, (__bridge void*)key));
        if (iterP != NULL) {
            VDSExpirableObject* object = (VDSExpirableObject*)CFBridgingRelease(**iterP);
            object = nil;
            _expireList->erase(*iterP);
            NSMapRemove(_expirationMap, (__bridge void*)key);
        }
        
        if (_configuration.tracksObjectUsage) {
            for (NSInteger count = [_usageList countForObject:key]; count > 0; count--) {
                [_usageList removeObject:key];
            }
        }
    }
    
    /// Remove the object at the end so that it and its key are retained until
    /// there are no further pointers to them.
    [_cacheObjects removeObjectForKey:key];

    [_coordinatorLock unlock];
}


- (void)removeAllObjects
{
    /// This method empties the cache and all associated tracking data
    /// effectively taking the cache back to a clean initialization state.
    [_coordinatorLock lock];

    NSArray* allKeys = NSAllMapTableKeys(_expirationMap);
    for (id key in allKeys) {
        std::list<void*>::iterator* iterP = ((std::list<void*>::iterator*)NSMapGet(_expirationMap, (__bridge void*)key));
        if (iterP != NULL) {
            VDSExpirableObject* object = (VDSExpirableObject*)CFBridgingRelease(**iterP);
            object = nil;
            _expireList->erase(*iterP);
            NSMapRemove(_expirationMap, (__bridge void*)key);
        }
    }
    
    [_cacheObjects removeAllObjects];
    NSResetMapTable(_evictionPolicyKeyMap);
    if (_oatList != NULL) { _oatList->clear(); }
    [_usageList removeAllObjects];

    [_coordinatorLock unlock];
}


- (id _Nullable)objectForKey:(id _Nonnull)key
{
    [_coordinatorLock lock];
    id object = [_cacheObjects objectForKey:key];
    [_coordinatorLock unlock];
    return object;
}


- (NSArray*)allObjects
{
    [_coordinatorLock lock];
    NSArray* objects = [_cacheObjects allValues];
    [_coordinatorLock unlock];
    return objects;
}


- (NSArray* _Nonnull)trackedObjects
{
    [_coordinatorLock lock];
    NSArray* trackedKeys = [self trackedKeys];
    NSArray* objects = [_cacheObjects objectsForKeys:trackedKeys notFoundMarker:[NSNull null]];
    [_coordinatorLock unlock];
    return objects;
}


- (NSArray* _Nonnull)untrackedObjects
{
    [_coordinatorLock lock];
    NSArray* untrackedKeys = [self untrackedKeys];
    NSArray* objects = [_cacheObjects objectsForKeys:untrackedKeys notFoundMarker:[NSNull null]];
    [_coordinatorLock unlock];
    return objects;
}


- (NSArray*)allKeys
{
    [_coordinatorLock lock];
    NSArray* keys = [_cacheObjects allKeys];
    [_coordinatorLock unlock];
    return keys;
}


- (NSArray* _Nonnull)trackedKeys
{
    [_coordinatorLock lock];
    NSArray* keys = [_evictionPolicyKeyMap copy];
    [_coordinatorLock unlock];
    return keys;
}


- (NSArray* _Nonnull)untrackedKeys
{
    [_coordinatorLock lock];
    NSSet* trackedKeys = [NSSet setWithArray:[self trackedKeys]];
    NSMutableSet* untrackedKeys = [NSMutableSet setWithArray:[_cacheObjects allKeys]];
    [untrackedKeys minusSet:trackedKeys];
    [_coordinatorLock unlock];
    return untrackedKeys.allObjects;
}


- (NSDictionary*)allObjectsAndKeys
{
    [_coordinatorLock lock];
    NSDictionary* objectsAndKeys = [_cacheObjects copy];
    [_coordinatorLock unlock];
    return objectsAndKeys;
}


- (NSDictionary* _Nonnull)trackedObjectsAndKeys
{
    [_coordinatorLock lock];
    NSArray* trackedKeys = [self trackedKeys];
    NSMutableDictionary* trackedObjectsAndKeys = [_cacheObjects copy];
    [trackedObjectsAndKeys removeObjectsForKeys:trackedKeys];
    [_coordinatorLock unlock];
    return trackedObjectsAndKeys;
}


- (NSDictionary* _Nonnull)untrackedObjectsAndKeys
{
    [_coordinatorLock lock];
    NSArray* untrackedKeys = [self untrackedKeys];
    NSMutableDictionary* untrackedObjectsAndKeys = [_cacheObjects copy];
    [untrackedObjectsAndKeys removeObjectsForKeys:untrackedKeys];
    [_coordinatorLock unlock];
    return untrackedObjectsAndKeys;
}



#pragma mark - Fast Enumeration Behaviors

- (NSUInteger)countByEnumeratingWithState:(nonnull NSFastEnumerationState *)state objects:(__unsafe_unretained id  _Nullable * _Nonnull)buffer count:(NSUInteger)len
{
    return [_cacheObjects countByEnumeratingWithState:state
                                               objects:buffer
                                                 count:len];
}



@end

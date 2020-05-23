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
#import "VDSMergableObject.h"


@interface VDSDatabaseCache ()


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


/// Maintains a list, in temporal order, of expirable objects. An expirable object
/// cotains a timestamp representing when an object in the cache should expire and
/// the object's associated key. Setting expiresObjects to YES will initialize the
/// expirationTable, otherwise the default value is nil.
///
@property(strong, readonly, nullable) NSMutableArray<VDSExpirableObject*>* expirationTable;


/// Maintains a list of keys for objects in the cache and each object's number of uses.
/// Setting tracksObjectUsage to YES will initialize the usageList, otherwise the default
/// value is nil.
///
@property(strong, readonly, nullable) NSCountedSet* usageList;


/// Maintains a list of keys for objects in the cache in the order in which they were added.
/// The most recent addition is at the highest index and the oldest addition is at index 0.
///
@property(strong, readonly, nonnull) NSMutableArray* evictionPolicyKeyList;


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


/// @summary The operation queue used by the cache to process eviction operations against its
/// cached objects. The queue may be suspended and /or its operations canceled to
/// prevent or pause evictions as needed.
///
@property(strong, readonly, nonnull) VDSOperationQueue* evictionQueue;


/// @summary The eviction operation class used by the cache to process object evictions.
///
@property(strong, readonly, nonnull) Class evictionOperationClass;


@end


@implementation VDSDatabaseCache


#pragma mark Properties

@synthesize configuration = _configuration;

@synthesize cacheObjects = _cacheObjects;
@synthesize expirationTable = _expirationTable;
@synthesize usageList = _usageList;
@synthesize evictionPolicyKeyList = _evictionPolicyKeyList;
@synthesize expirationTimingMapKey = _expirationTimingMapKey;
@synthesize expirationTimingMap = _expirationTimingMap;
@synthesize coordinatorLock = _coordinatorLock;
@synthesize evictionLoop = _evictionLoop;
@synthesize evictionQueue = _evictionQueue;
@synthesize evictionOperationClass = _evictionOperationClass;


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
    _evictionPolicyKeyList = [NSMutableArray new];
    _evictionLoop = [NSTimer timerWithTimeInterval:_configuration.evictionInterval
                                            target:self
                                          selector:@selector(processEvictions:)
                                          userInfo:nil
                                           repeats:YES];
    _evictionQueue = [VDSOperationQueue new];
    _evictionOperationClass = NSClassFromString(_configuration.evictionOperationClassName);
}


- (void)configureObjectTrackingSystem
{
    _usageList = _configuration.tracksObjectUsage ? [NSCountedSet new] : nil;
}


- (void)configureExpirationSystem
{
    _expirationTable = _configuration.expiresObjects ? [NSMutableArray new] : nil;
    _expirationTimingMap = [_configuration.expirationTimingMap copy];
    _expirationTimingMapKey = [_configuration.expirationTimingMapKey copy];
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


#pragma mark Operation Queue Delegate Behaviors

- (void)operationQueue:(VDSOperationQueue * _Nonnull)queue operationDidFinish:(NSOperation * _Nonnull)operation {
    
}

- (BOOL)operationQueue:(VDSOperationQueue * _Nonnull)queue shouldAddOperation:(NSOperation * _Nonnull)operation {
    return YES;
}

- (void)operationQueue:(VDSOperationQueue * _Nonnull)queue willAddOperation:(NSOperation * _Nonnull)operation {
    
}



#pragma mark - Main Public Behaviors

- (void)processEvictions:(NSTimer* _Nonnull)timer
{
    /// Launches the eviction operation unless one exists on the queue.
    if (self.evictionQueue.operationCount == 0) {
        id evictionOperation = [_evictionOperationClass new];
        [_evictionQueue addOperation:evictionOperation];
    }
    return;
}


- (BOOL)evictObject:(id _Nonnull)key
              error:(NSError* __autoreleasing _Nullable * _Nullable)error
{
    BOOL success = NO;
    
    [_coordinatorLock lock];
    /// Object eviction depends on whether usage will prevent eviction.
    NSUInteger usageCount = [_usageList countForObject:key];
    
    if (_configuration.evictsObjectsInUse == NO && usageCount > 0) {
        if (error != NULL) {
            id object = [_cacheObjects objectForKey:key];
            *error = [NSError errorWithDomain:VDSKitErrorDomain
                                         code:VDSCacheObjectInUse
                                     userInfo:@{NSDebugDescriptionErrorKey: VDS_OBJECT_IN_USE_MESSAGE(object, key)}];
        }
        success = NO;
    } else {
        // Evict the object
        [self removeObjectForKey:key];
        success = YES;
    }
    [_coordinatorLock unlock];
    
    return success;
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
    [self setObject:object forKey:key tracked:NO];
    [_coordinatorLock unlock];
}


- (void)setObject:(id _Nonnull)object forKey:(id _Nonnull)key tracked:(BOOL)tracked
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
        [object conformsToProtocol:@protocol(VDSMergableObject)] &&
        [cachedObject conformsToProtocol:@protocol(VDSMergableObject)]) {
        id mergableObject = (id<VDSMergableObject>)object;
        for (id key in [mergableObject mergableKeys]) {
            id value = [mergableObject valueForKey:key];
            [cachedObject mergeValue:value forKey:key];
        }
    } else {
        [_cacheObjects setObject:object forKey:key];
    }
    
    if (_configuration.expiresObjects) {
        /// To keep the eviction policy list (FIFO or LIFO) accurate,
        /// it's necessary to remove the last instance of the key
        /// that was added to the list before adding the new entry.
        [_evictionPolicyKeyList removeObject:key];
        [_evictionPolicyKeyList addObject:key];
    
        /// If expiration is supported, the timing must be calculated (even if it's just
        /// read in from a value in object or key). As with the  eviction policy list,
        /// the expirable object must be removed and a new one created. Expirable object
        /// overrides hash so that equality (and therefore searching) is a function of the
        /// object value in expirable, not the timestamp which is used as a sorting key to
        /// speed up eviction.
        [_expirationTable removeObject:key];
        id timingKey = [_expirationTimingMapKey expressionValueWithObject:key
                                                                context:[NSMutableDictionary dictionaryWithObject:[_cacheObjects objectForKey:key] forKey:VDSEntrySnapshotKey]];
        NSDate* expiration = [_expirationTimingMap[timingKey] expressionValueWithObject:key
                                                                              context:[NSMutableDictionary dictionaryWithObject:[_cacheObjects objectForKey:key] forKey:VDSEntrySnapshotKey]];
        VDSExpirableObject* expirable = [[VDSExpirableObject alloc] initWithExpiration:expiration object:key];
        [_expirationTable addObject:expirable];
        [_expirationTable sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"expiration"
                                                                               ascending:YES]]];
    
        /// Usage Tracking
        if (_configuration.tracksObjectUsage) { [_usageList addObject:key]; }
    }
    /// Once all of the changes have been made, unlock the coordinator.
    [_coordinatorLock unlock];
}

- (void)removeObjectForKey:(id _Nonnull)key
{
    /// Removal mechanics depends on whether an object is tracked.
    [_coordinatorLock lock];
    [_cacheObjects removeObjectForKey:key];
    if (!_configuration.expiresObjects || [_evictionPolicyKeyList containsObject:key] == NO) {
        [_evictionPolicyKeyList removeObject:key];
        NSUInteger index = [_expirationTable indexOfObject:key];
        [_expirationTable removeObjectAtIndex:index];
        if (_configuration.tracksObjectUsage) {
            for (NSInteger count = [_usageList countForObject:key]; count > 0; count--) {
                [_usageList removeObject:key];
            }
        }
    }
    [_coordinatorLock unlock];
}

- (void)removeAllObjects
{
    /// This method empties the cache and all associated tracking data
    /// effectively taking the cache back to a clean initialization state.
    [_coordinatorLock lock];
    [_cacheObjects removeAllObjects];
    [_evictionPolicyKeyList removeAllObjects];
    [_expirationTable removeAllObjects];
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
    NSArray* keys = [_evictionPolicyKeyList copy];
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

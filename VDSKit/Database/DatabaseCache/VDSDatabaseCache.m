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


/// @summary A dispatch queue used to coordinate cache tracking reads and writes. Subclasses should
/// use the syncQueue and/or lock objects, barriers, etc. to create facades that ensure reading of
/// and writing to the cache is thread safe.
///
@property(strong, readonly, nonnull) dispatch_queue_t syncQueue;


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
@synthesize syncQueue = _syncQueue;
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
        _syncQueue = dispatch_queue_create("VDSDatabaseCacheSyncQueue", DISPATCH_QUEUE_SERIAL);
        _coordinatorLock = [NSRecursiveLock new];
        if (_expiresObjects) {
            [self configureExpirationSystem];
            [self configureEvictionSystem];
            if (_configuration.tracksObjectUsage) { [self configureObjectTrackingSystem]; }
        }
    }
    return self;
}


- (void)configureEvictionSystem
{
    _evictionPolicyKeyList = [NSMutableArray new];
    _evictionLoop = [NSTimer timerWithTimeInterval:_evictionInterval
                                            target:self
                                          selector:@selector(processEvictions:)
                                          userInfo:nil
                                           repeats:NO];
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
    return [self initWithConfiguration:configuration];
}


- (void)encodeWithCoder:(nonnull NSCoder *)coder
{
    [coder encodeObject:_configuration forKey:NSStringFromSelector(@selector(configuration))];
}


#pragma mark Operation Queue Delegate Behaviors

- (void)operationQueue:(VDSOperationQueue * _Nonnull)queue operationDidFinish:(NSOperation * _Nonnull)operation {
    
}

- (BOOL)operationQueue:(VDSOperationQueue * _Nonnull)queue shouldAddOperation:(NSOperation * _Nonnull)operation {
    return NO;
}

- (void)operationQueue:(VDSOperationQueue * _Nonnull)queue willAddOperation:(NSOperation * _Nonnull)operation {
    
}



#pragma mark - Main Public Behaviors

- (void)processEvictions:(NSTimer* _Nonnull)timer
{
    return;
}

- (BOOL)addTrackedObject:(id _Nonnull)object
               usingKey:(id _Nonnull)key
{
    BOOL success = YES;
    
    [_cacheObjects setObject:object forKey:key];
    
    // To keep the eviction policy list (FIFO or LIFO) accurate,
    // it's necessary to remove the last instance of the key
    // that was added to the list before adding the new entry.
    [_evictionPolicyKeyList removeObject:key];
    [_evictionPolicyKeyList addObject:key];
    
    // If expiration is supported, the timing must be calculated (even if it's just
    // read in from a value in object or key). As with the  eviction policy list,
    // the expirable object must be removed and a new one created. Expirable object
    // overrides hash so that equality (and therefore searching) is a function of the
    // object value in expirable, not the timestamp which is used as a sorting key to
    // speed up eviction.
    if (_expiresObjects == YES) {
        [_expirationTable removeObject:object];
        id timingKey = [_expirationTimingMapKey expressionValueWithObject:key
                                                                context:[NSMutableDictionary dictionaryWithObject:object forKey:@""]];
        NSDate* expiration = [_expirationTimingMap[timingKey] expressionValueWithObject:key
                                                                              context:[NSMutableDictionary dictionaryWithObject:object forKey:VDSEntrySnapshotKey]];
        VDSExpirableObject* expirable = [[VDSExpirableObject alloc] initWithExpiration:expiration object:object];
        [_expirationTable addObject:expirable];
        [_expirationTable sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"expiration"
                                                                               ascending:YES]]];
    }
    
    return success;
}

- (BOOL)evictObject:(id _Nonnull)key
              error:(NSError* __autoreleasing _Nullable * _Nullable)error
{
    return NO;
}

- (BOOL)incrementUsageCount:(id _Nonnull)key
error:(NSError* __autoreleasing _Nullable * _Nullable)error
{
    return YES;
}


- (BOOL)decrementUsageCount:(id _Nonnull)key
error:(NSError* __autoreleasing _Nullable * _Nullable)error
{
    return YES;
}


#pragma mark - Supporting Behaviors

- (void)setObject:(id _Nonnull)object forKey:(id _Nonnull)key
{
    
}

- (void)setObject:(id _Nonnull)object forKey:(id _Nonnull)key tracked:(BOOL)tracked
{
    
}

- (void)removeObjectForKey:(id _Nonnull)key
{
    
}

- (void)removeAllObjects
{
    
}

- (id _Nullable)objectForKey:(id _Nonnull)key
{
    return nil;
}

- (NSArray*)allObjects
{
    return nil;
}

- (NSArray* _Nonnull)trackedObjects
{
    return nil;
}

- (NSArray* _Nonnull)untrackedObjects
{
    return nil;
}

- (NSArray*)allKeys
{
    return nil;
}

- (NSArray* _Nonnull)trackedKeys
{
    return nil;
}

- (NSArray* _Nonnull)untrackedKeys
{
    return nil;
}

- (NSDictionary*)allObjectsAndKeys
{
    return nil;
}

- (NSDictionary* _Nonnull)trackedObjectsAndKeys
{
    return nil;
}

- (NSDictionary* _Nonnull)untrackedObjectsAndKeys
{
    return nil;
}


#pragma mark - Utility Behaviors

- (NSUInteger)countByEnumeratingWithState:(nonnull NSFastEnumerationState *)state objects:(__unsafe_unretained id  _Nullable * _Nonnull)buffer count:(NSUInteger)len
{
    return [_cacheObjects countByEnumeratingWithState:state
                                               objects:buffer
                                                 count:len];
}


#pragma mark - Private Behaviors

- (BOOL)evictTrackedObject:(id _Nonnull)key
                   error:(NSError *__autoreleasing  _Nullable * _Nullable)error
{
    BOOL success = YES;
    
    id object = [_cacheObjects objectForKey:key];
    
    if (object == nil) { success = NO; }
    
    if (success == YES && _evictsObjectsInUse == YES && [_usageList countForObject:object] > 0) {
        success = NO;
        if (error != NULL) {
            *error = [NSError errorWithDomain: VDSKitErrorDomain
                                         code:VDSUnableToRemoveObject
                                     userInfo:@{NSDebugDescriptionErrorKey: VDS_OBJECT_IN_USE_MESSAGE(object, key)}];
        }
    }
    
    if (success == YES) {
        [_evictionPolicyKeyList removeObject:object];
        if (_expiresObjects == YES) {
            [_expirationTable removeObject:object];
        }
    }
    
    return success;
}

@end

//
//  VDSDatabaseCacheConfiguration.h
//  VDSKit
//
//  Created by Erikheath Thomas on 5/21/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../../VDSConstants.h"


@interface VDSDatabaseCacheConfiguration : NSObject <NSCopying, NSMutableCopying, NSSecureCoding> {
    @protected
    BOOL _expiresObjects;
    NSInteger _preferredMaxObjectCount;
    VDSEvictionPolicy _evictionPolicy;
    BOOL _evictsOnLowMemory;
    BOOL _tracksObjectUsage;
    BOOL _evictsObjectsInUse;
    BOOL _replacesObjectsOnUpdate;
    NSTimeInterval _evictionInterval;
    BOOL _archivesUntrackedObjects;
    NSExpression* _expirationTimingMapKey;
    NSDictionary* _expirationTimingMap;
}

#pragma mark Cache Configuration Properties

/// @summary Determines whether the cache records an expiration date for an object that
/// is added to the cache via the addTrackedObject method. The default is NO.
///
/// Corresponds to the VDSExpiresObjectKey.
///
@property(readonly, nonatomic) BOOL expiresObjects;


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
@property(readonly, nonatomic) NSInteger preferredMaxObjectCount;


/// @summary Determines whether objects will be selected for eviction in LIFO (last in, first out)
/// or FIFO (first in, first out) order when being processed for eviction based on
/// cache size preferences. The default is VDSLIFOPolicy.
///
/// Corresponds to the VDSEvictionPolicyKey.
///
@property(readonly, nonatomic) VDSEvictionPolicy evictionPolicy;


/// @summary Determines whether the cache will dispatch an eviction operation when a low memory notification
/// is received. The default is NO.
///
/// Corresponds to the VDSEvictsOnLowMemoryKey.
///
@property(readonly, nonatomic) BOOL evictsOnLowMemory;


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
@property(readonly, nonatomic) BOOL tracksObjectUsage;


/// @summary Determines whether the cache will evict objects that have a usage value of one (1)
/// or higher. The default is NO.
///
/// Corresponds to the VDSEvictsObjectsInUseKey.
///
@property(readonly, nonatomic) BOOL evictsObjectsInUse;


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
@property(readonly, nonatomic) BOOL replacesObjectsOnUpdate;


/// @summary The dispatch interval, in seconds, between eviction operations.
/// The default interval is 300 seconds.
///
/// Corresponds to the VDSEvictionIntervalKey.
///
@property(readonly, nonatomic) NSTimeInterval evictionInterval;


/// Determines whether the cache will archive untracked objects when encoding itself.
/// The default is NO.
///
/// Corresponds to the VDSArchivesUntrackedObjectsKey.
///
@property(readonly, nonatomic) BOOL archivesUntrackedObjects;


/// @summary An expression that must evaluate to one of the keys used in the expirationTimingMap.
/// The expression is evaluated against an incoming key and with a NSMutableDictionary as
/// a context object that contains the incoming object associated with VDSEntrySnapshotKey.
///
/// @note Setting expiresObjects to YES requires an expirationTimingMap and expriationTimingMapKey when
/// configuring a VDSDatabaseCache, otherwise the default value is nil.
///
@property(strong, readonly, nullable, nonatomic) NSExpression* expirationTimingMapKey;


/// @summary A map of expressions that evaluate to an expriation date for incoming objects
/// with keys that must be determinable using the expirationTimingMapKey expression. Each
/// expression is evaluated against an incoming key and with a NSMutableDictionary as
/// a context object that contains a the incoming object associated with VDSEntrySnapshotKey.
///
/// @note Setting expiresObjects to YES requires an expirationTimingMap and expriationTimingMapKey when
/// configuring a VDSDatabaseCache, otherwise the default value is nil.
///
@property(strong, readonly, nullable, nonatomic) NSDictionary<id, NSExpression*>* expirationTimingMap;


#pragma mark Object Lifecycle

- (instancetype _Nullable)init;

- (instancetype _Nullable)initWithDictionary:(NSDictionary* _Nullable)dictionary NS_DESIGNATED_INITIALIZER;

- (instancetype _Nullable)initWithCoder:(NSCoder * _Nonnull)coder NS_DESIGNATED_INITIALIZER;

@end


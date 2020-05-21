//
//  VDSConstants.h
//  VDSKit
//
//  Created by Erikheath Thomas on 4/17/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark - VDSKit Cache Constants -

typedef NSString* const VDSCacheEntryKey;
FOUNDATION_EXPORT VDSCacheEntryKey VDSEntryTimestampKey;
FOUNDATION_EXPORT VDSCacheEntryKey VDSEntryUUIDKey;
FOUNDATION_EXPORT VDSCacheEntryKey VDSEntryEntityNameKey;
FOUNDATION_EXPORT VDSCacheEntryKey VDSEntrySnapshotKey;

typedef NSString* const VDSEvictionCycleKey;
FOUNDATION_EXPORT VDSEvictionCycleKey VDSExpirationCycleKey;
FOUNDATION_EXPORT VDSEvictionCycleKey VDSFIFOPolicyCycleKey;
FOUNDATION_EXPORT VDSEvictionCycleKey VDSLIFOPolicyCycleKey;
FOUNDATION_EXPORT VDSEvictionCycleKey VDSUnknownCycleKey;

typedef NSString* const VDSCacheConfigurationKey;
FOUNDATION_EXPORT VDSCacheConfigurationKey VDSCacheExpiresObjectsKey;
FOUNDATION_EXPORT VDSCacheConfigurationKey VDSCachePreferredMaxObjectCountKey;
FOUNDATION_EXPORT VDSCacheConfigurationKey VDSCacheEvictionPolicyKey;
FOUNDATION_EXPORT VDSCacheConfigurationKey VDSCacheEvictsOnLowMemoryKey;
FOUNDATION_EXPORT VDSCacheConfigurationKey VDSCacheTracksObjectUsageKey;
FOUNDATION_EXPORT VDSCacheConfigurationKey VDSCacheEvictsObjectsInUseKey;
FOUNDATION_EXPORT VDSCacheConfigurationKey VDSCacheReplacesObjectsOnUpdateKey;
FOUNDATION_EXPORT VDSCacheConfigurationKey VDSCacheEvictionIntervalKey;
FOUNDATION_EXPORT VDSCacheConfigurationKey VDSCacheArchivesUntrackedObjectsKey;
FOUNDATION_EXPORT VDSCacheConfigurationKey VDSCacheExpirationTimingMapExpressionKey;
FOUNDATION_EXPORT VDSCacheConfigurationKey VDSCacheExpirationTimingMapKey;
FOUNDATION_EXPORT VDSCacheConfigurationKey VDSCacheEvictionOperationClassNameKey;



/// The VDSEvictionPolicy indicates how objects should be removed from a cache.
/// VDSFIFOPolicy indicates a First In, First Out strategy.
/// VDSLIFOPolicy indicates a Last In, First Out strategy.
typedef NS_ENUM(NSUInteger, VDSEvictionPolicy) {
    VDSFIFOPolicy = 0,
    VDSLIFOPolicy = 1,
};


#pragma mark - Operation Constants -

typedef NS_ENUM(NSUInteger, VDSOperationState) {
    VDSOperationInitialized = 1,
    VDSOperationPending,
    VDSOperationEvaluating,
    VDSOperationReady,
    VDSOperationExecuting,
    VDSOperationFinishing,
    VDSOperationFinished,
};

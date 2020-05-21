//
//  VDSConstants.m
//  VDSKit
//
//  Created by Erikheath Thomas on 4/17/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import "VDSConstants.h"

#pragma mark - VDSKit Cache Constants

VDSCacheEntryKey VDSEntryTimestampKey = @"VDSEntryTimestampKey";
VDSCacheEntryKey VDSEntryUUIDKey = @"VDSEntryUUIDKey";
VDSCacheEntryKey VDSEntryEntityNameKey = @"VDSEntryEntityNameKey";
VDSCacheEntryKey VDSEntrySnapshotKey = @"VDSEntrySnapshotKey";

VDSEvictionCycleKey VDSExpirationCycleKey = @"VDSExpirationCycleKey";
VDSEvictionCycleKey VDSFIFOPolicyCycleKey = @"VDSFIFOPolicyCycleKey";
VDSEvictionCycleKey VDSLIFOPolicyCycleKey = @"VDSLIFOPolicyCycleKey";
VDSEvictionCycleKey VDSUnknownCycleKey = @"VDSUnknownCycleKey";

VDSCacheConfigurationKey VDSCacheExpiresObjectsKey = @"expiresObjects";
VDSCacheConfigurationKey VDSCachePreferredMaxObjectCountKey = @"preferredMaxObjectCount";
VDSCacheConfigurationKey VDSCacheEvictionPolicyKey = @"evictionPolicy";
VDSCacheConfigurationKey VDSCacheEvictsOnLowMemoryKey = @"evictsOnLowMemory";
VDSCacheConfigurationKey VDSCacheTracksObjectUsageKey = @"tracksObjectUsage";
VDSCacheConfigurationKey VDSCacheEvictsObjectsInUseKey = @"evictsObjectsInUse";
VDSCacheConfigurationKey VDSCacheReplacesObjectsOnUpdateKey = @"replacesObjectsOnUpdate";
VDSCacheConfigurationKey VDSCacheEvictionIntervalKey = @"evictionInterval";
VDSCacheConfigurationKey VDSCacheArchivesUntrackedObjectsKey = @"archivesUntrackedObjects";
VDSCacheConfigurationKey VDSCacheExpirationTimingMapExpressionKey = @"expirationTimingMapKey";
VDSCacheConfigurationKey VDSCacheExpirationTimingMapKey = @"expirationTimingMap";
VDSCacheConfigurationKey VDSCacheEvictionOperationClassNameKey = @"evictionOperationClassName";

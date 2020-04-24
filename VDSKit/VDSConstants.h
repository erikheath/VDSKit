//
//  VDSConstants.h
//  VDSKit
//
//  Created by Erikheath Thomas on 4/17/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark - VDSKit Cache Constants -

typedef NSString* const VDSCacheKey;
FOUNDATION_EXPORT VDSCacheKey VDSEntryTimestampKey;
FOUNDATION_EXPORT VDSCacheKey VDSEntryUUIDKey;
FOUNDATION_EXPORT VDSCacheKey VDSEntryEntityNameKey;
FOUNDATION_EXPORT VDSCacheKey VDSEntrySnapshotKey;

typedef NSString* const VDSEvictionCycleKey;
FOUNDATION_EXPORT VDSEvictionCycleKey VDSExpirationCycleKey;
FOUNDATION_EXPORT VDSEvictionCycleKey VDSFIFOPolicyCycleKey;
FOUNDATION_EXPORT VDSEvictionCycleKey VDSLIFOPolicyCycleKey;
FOUNDATION_EXPORT VDSEvictionCycleKey VDSUnknownCycleKey;


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

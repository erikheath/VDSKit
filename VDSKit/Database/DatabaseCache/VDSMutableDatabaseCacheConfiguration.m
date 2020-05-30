//
//  VDSMutableDatabaseCacheConfiguration.m
//  VDSKit
//
//  Created by Erikheath Thomas on 5/21/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import "VDSMutableDatabaseCacheConfiguration.h"





@implementation VDSMutableDatabaseCacheConfiguration

@dynamic expiresObjects;
@dynamic preferredMaxObjectCount;
@dynamic evictionPolicy;
@dynamic evictsOnLowMemory;
@dynamic tracksObjectUsage;
@dynamic evictsObjectsInUse;
@dynamic replacesObjectsOnUpdate;
@dynamic evictionInterval;
@dynamic archivesUntrackedObjects;
@dynamic expirationTimingMapKey;
@dynamic expirationTimingMap;


- (void)setExpiresObjects:(BOOL)expiresObjects
{
    _expiresObjects = expiresObjects;
}


- (void)setPreferredMaxObjectCount:(NSInteger)preferredMaxObjectCount
{
    _preferredMaxObjectCount = preferredMaxObjectCount;
}


- (void)setEvictionPolicy:(VDSEvictionPolicy)evictionPolicy
{
    _evictionPolicy = evictionPolicy;
}


- (void)setEvictsOnLowMemory:(BOOL)evictsOnLowMemory
{
    _evictsOnLowMemory = evictsOnLowMemory;
}


- (void)setTracksObjectUsage:(BOOL)tracksObjectUsage
{
    _tracksObjectUsage = tracksObjectUsage;
}


- (void)setEvictsObjectsInUse:(BOOL)evictsObjectsInUse
{
    _evictsObjectsInUse = evictsObjectsInUse;
}


- (void)setReplacesObjectsOnUpdate:(BOOL)replacesObjectsOnUpdate
{
    _replacesObjectsOnUpdate = replacesObjectsOnUpdate;
}


- (void)setEvictionInterval:(NSTimeInterval)evictionInterval
{
    _evictionInterval = evictionInterval;
}


- (void)setArchivesUntrackedObjects:(BOOL)archivesUntrackedObjects
{
    _archivesUntrackedObjects = archivesUntrackedObjects;
}


- (void)setExpirationTimingMapKey:(NSExpression *)expirationTimingMapKey
{
    _expirationTimingMapKey = expirationTimingMapKey;
}


- (void)setExpirationTimingMap:(NSDictionary<id,NSExpression *> *)expirationTimingMap
{
    _expirationTimingMap = expirationTimingMap;
}


@end

//
//  VDSDatabaseCacheConfiguration.m
//  VDSKit
//
//  Created by Erikheath Thomas on 5/21/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import "VDSDatabaseCacheConfiguration.h"
#import "VDSMutableDatabaseCacheConfiguration.h"


@interface VDSDatabaseCacheConfiguration()


@end


@implementation VDSDatabaseCacheConfiguration

@synthesize expiresObjects = _expiresObjects;
@synthesize preferredMaxObjectCount = _preferredMaxObjectCount;
@synthesize evictionPolicy = _evictionPolicy;
@synthesize evictsOnLowMemory = _evictsOnLowMemory;
@synthesize tracksObjectUsage = _tracksObjectUsage;
@synthesize evictsObjectsInUse = _evictsObjectsInUse;
@synthesize replacesObjectsOnUpdate = _replacesObjectsOnUpdate;
@synthesize evictionInterval = _evictionInterval;
@synthesize archivesUntrackedObjects = _archivesUntrackedObjects;
@synthesize expirationTimingMapKey = _expirationTimingMapKey;
@synthesize expirationTimingMap = _expirationTimingMap;
@synthesize evictionOperationClassName = _evictionOperationClassName;


#pragma mark Object Lifecycle

- (instancetype)init
{
    return [self initWithDictionary:@{}];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self != nil) {
        _expiresObjects = [dictionary[VDSCacheExpiresObjectsKey] boolValue];
        _preferredMaxObjectCount = [dictionary[VDSCachePreferredMaxObjectCountKey] integerValue];
        _evictionPolicy = [dictionary[VDSCacheEvictionPolicyKey] integerValue];
        _evictsOnLowMemory = [dictionary[VDSCacheEvictsOnLowMemoryKey] boolValue];
        _tracksObjectUsage = [dictionary[VDSCacheTracksObjectUsageKey] boolValue];
        _evictsObjectsInUse = [dictionary[VDSCacheEvictsObjectsInUseKey] boolValue];
        _replacesObjectsOnUpdate = [dictionary[VDSCacheReplacesObjectsOnUpdateKey] boolValue];
        _evictionInterval = [dictionary[VDSCacheEvictionIntervalKey] doubleValue];
        _archivesUntrackedObjects = [dictionary[VDSCacheArchivesUntrackedObjectsKey] boolValue];
        _expirationTimingMapKey = [dictionary[VDSCacheExpirationTimingMapExpressionKey] copy];
        _expirationTimingMap = [dictionary[VDSCacheExpirationTimingMapKey] copy];
        _evictionOperationClassName = dictionary[VDSCacheEvictionOperationClassNameKey];
    }
    return self;
}


#pragma mark Coding Support

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (instancetype _Nullable)initWithCoder:(nonnull NSCoder *)coder {
    self = [super init];
    if (self != nil) {
        _expiresObjects = [coder decodeBoolForKey:NSStringFromSelector(@selector(expiresObjects))];
        _preferredMaxObjectCount = [coder decodeIntegerForKey:NSStringFromSelector(@selector(preferredMaxObjectCount))];
        _evictionPolicy = [coder decodeIntegerForKey:NSStringFromSelector(@selector(evictionPolicy))];
        _evictsOnLowMemory = [coder decodeBoolForKey:NSStringFromSelector(@selector(evictsOnLowMemory))];
        _tracksObjectUsage = [coder decodeBoolForKey:NSStringFromSelector(@selector(tracksObjectUsage))];
        _evictsObjectsInUse = [coder decodeBoolForKey:NSStringFromSelector(@selector(evictsObjectsInUse))];
        _replacesObjectsOnUpdate = [coder decodeBoolForKey:NSStringFromSelector(@selector(replacesObjectsOnUpdate))];
        _evictionInterval = [coder decodeDoubleForKey:NSStringFromSelector(@selector(evictionInterval))];
        _archivesUntrackedObjects = [coder decodeBoolForKey:NSStringFromSelector(@selector(archivesUntrackedObjects))];
        _expirationTimingMapKey = [coder decodeObjectOfClass:[NSExpression class] forKey:NSStringFromSelector(@selector(expirationTimingMapKey))];
        _expirationTimingMap = [coder decodeObjectOfClass:[NSDictionary class] forKey:NSStringFromSelector(@selector(expirationTimingMap))];
        _evictionOperationClassName = [coder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(evictionOperationClassName))];
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeBool:_expiresObjects forKey:NSStringFromSelector(@selector(expiresObjects))];
    [coder encodeInteger:_preferredMaxObjectCount forKey:NSStringFromSelector(@selector(preferredMaxObjectCount))];
    [coder encodeInteger:_evictionPolicy forKey:NSStringFromSelector(@selector(evictionPolicy))];
    [coder encodeBool:_evictsOnLowMemory forKey:NSStringFromSelector(@selector(evictsOnLowMemory))];
    [coder encodeBool:_tracksObjectUsage forKey:NSStringFromSelector(@selector(tracksObjectUsage))];
    [coder encodeBool:_evictsObjectsInUse forKey:NSStringFromSelector(@selector(evictsObjectsInUse))];
    [coder encodeBool:_replacesObjectsOnUpdate forKey:NSStringFromSelector(@selector(replacesObjectsOnUpdate))];
    [coder encodeDouble:_evictionInterval forKey:NSStringFromSelector(@selector(evictionInterval))];
    [coder encodeBool:_archivesUntrackedObjects forKey:NSStringFromSelector(@selector(archivesUntrackedObjects))];
    [coder encodeObject:_expirationTimingMapKey forKey:NSStringFromSelector(@selector(expirationTimingMapKey))];
    [coder encodeObject:_expirationTimingMap forKey:NSStringFromSelector(@selector(expirationTimingMap))];
    [coder encodeObject:_evictionOperationClassName forKey:NSStringFromSelector(@selector(evictionOperationClassName))];
}


#pragma mark Copying Support

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    NSMutableDictionary* dictionary = [NSMutableDictionary new];
    
    dictionary[VDSCacheExpiresObjectsKey] = @(_expiresObjects);
    dictionary[VDSCachePreferredMaxObjectCountKey] = @(_preferredMaxObjectCount);
    dictionary[VDSCacheEvictionPolicyKey] = @(_evictionPolicy);
    dictionary[VDSCacheEvictsOnLowMemoryKey] = @(_evictsOnLowMemory);
    dictionary[VDSCacheTracksObjectUsageKey] = @(_tracksObjectUsage);
    dictionary[VDSCacheEvictsObjectsInUseKey] = @(_evictsObjectsInUse);
    dictionary[VDSCacheReplacesObjectsOnUpdateKey] = @(_replacesObjectsOnUpdate);
    dictionary[VDSCacheEvictionIntervalKey] = @(_evictionInterval);
    dictionary[VDSCacheArchivesUntrackedObjectsKey] = @(_archivesUntrackedObjects);
    dictionary[VDSCacheExpirationTimingMapExpressionKey] = [_expirationTimingMapKey copy];
    dictionary[VDSCacheExpirationTimingMapKey] = [_expirationTimingMap copy];
    dictionary[VDSCacheEvictionOperationClassNameKey] = [_evictionOperationClassName copy];
    
    return [[VDSDatabaseCacheConfiguration alloc] initWithDictionary:dictionary];
}


#pragma mark Mutable Copying Support

- (nonnull id)mutableCopyWithZone:(nullable NSZone *)zone {
    NSMutableDictionary* dictionary = [NSMutableDictionary new];
    
    dictionary[VDSCacheExpiresObjectsKey] = @(_expiresObjects);
    dictionary[VDSCachePreferredMaxObjectCountKey] = @(_preferredMaxObjectCount);
    dictionary[VDSCacheEvictionPolicyKey] = @(_evictionPolicy);
    dictionary[VDSCacheEvictsOnLowMemoryKey] = @(_evictsOnLowMemory);
    dictionary[VDSCacheTracksObjectUsageKey] = @(_tracksObjectUsage);
    dictionary[VDSCacheEvictsObjectsInUseKey] = @(_evictsObjectsInUse);
    dictionary[VDSCacheReplacesObjectsOnUpdateKey] = @(_replacesObjectsOnUpdate);
    dictionary[VDSCacheEvictionIntervalKey] = @(_evictionInterval);
    dictionary[VDSCacheArchivesUntrackedObjectsKey] = @(_archivesUntrackedObjects);
    dictionary[VDSCacheExpirationTimingMapExpressionKey] = [_expirationTimingMapKey copy];
    dictionary[VDSCacheExpirationTimingMapKey] = [_expirationTimingMap copy];


    return [[VDSMutableDatabaseCacheConfiguration alloc] initWithDictionary:dictionary];

}



@end

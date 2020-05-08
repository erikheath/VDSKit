//
//  VDSCache.m
//  VDSKit
//
//  Created by Erikheath Thomas on 4/20/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import "VDSDatabaseCache.h"
#import "VDSErrorConstants.h"
#import "VDSExpirableObject.h"




@implementation VDSDatabaseCache


#pragma mark - Object Lifecycle

+(BOOL)supportsSecureCoding { return YES; }

- (void)encodeWithCoder:(nonnull NSCoder *)coder
{
    [coder encodeBool:_expiresObjects
               forKey:NSStringFromSelector(@selector(expiresObjects))];
    [coder encodeBool:_evictsOnLowMemory
               forKey:NSStringFromSelector(@selector(evictsOnLowMemory))];
    [coder encodeInteger:_evictionPolicy
                  forKey:NSStringFromSelector(@selector(evictionPolicy))];
    [coder encodeInteger:_preferredMaxObjectCount
                  forKey:NSStringFromSelector(@selector(preferredMaxObjectCount))];
    [coder encodeBool:_tracksObjectUsage
               forKey:NSStringFromSelector(@selector(tracksObjectUsage))];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder
{
    self = [super init];
    if (self != nil) {
        _expiresObjects = [coder decodeBoolForKey:NSStringFromSelector(@selector(expiresObjects))];
        _evictsOnLowMemory = [coder decodeBoolForKey:NSStringFromSelector(@selector(evictsOnLowMemory))];
        _evictionPolicy = [coder decodeIntegerForKey:NSStringFromSelector(@selector(evictionPolicy))];
        _preferredMaxObjectCount = [coder decodeIntegerForKey:NSStringFromSelector(@selector(preferredMaxObjectCount))];
        _tracksObjectUsage = [coder decodeBoolForKey:NSStringFromSelector(@selector(tracksObjectUsage))];
    }
    return self;
}


#pragma mark - Main Public Behaviors

- (BOOL)processEvictions:(NSError *__autoreleasing  _Nullable *)error
{
    BOOL success = YES;

    return success;
}

- (BOOL)evictTrackedObject:(id _Nonnull)key
                   error:(NSError *__autoreleasing  _Nullable * _Nullable)error
{
    BOOL success = YES;
    
    id object = [_cacheObjects objectForKey:key];
    
    if (object == nil) { success = NO; }
    
    if (success == YES && _doesNotEvictObjectsInUse == YES && [_usageList countForObject:object] > 0) {
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



#pragma mark - Utility Behaviors

- (NSUInteger)countByEnumeratingWithState:(nonnull NSFastEnumerationState *)state objects:(__unsafe_unretained id  _Nullable * _Nonnull)buffer count:(NSUInteger)len
{
    return [_cacheObjects countByEnumeratingWithState:state
                                               objects:buffer
                                                 count:len];
}


@end

//
//  VDSQueryCache.m
//  VDSKit
//
//  Created by Erikheath Thomas on 4/17/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import "VDSQueryCache.h"
#import "VDSConstants.h"
#import "VDSErrorConstants.h"

@interface VDSQueryCache()

@property(strong, readonly, nonnull) NSMutableDictionary* queryCache;
/* {key(query representation) : { key(timestamp) : value(timestamp);
                                  key(UUID) : value(UUID);
                                  key(entity) : value(name);
                                  key(snapshotIDs) : value( [rowID] )
   }
 */

@property(strong, readonly, nonnull) NSMutableSet* absentCacheObjects;

@end

@implementation VDSQueryCache


#pragma mark - Object Lifecycle
- (instancetype)init
{
    self = [super init];
    if (self) {
        _queryCache = [NSMutableDictionary new];
    }
    return self;

}


#pragma mark Secure Coding

+ (BOOL)supportsSecureCoding { return YES; }

- (void)encodeWithCoder:(nonnull NSCoder*)coder {
    [coder encodeObject:_queryCache
                 forKey:NSStringFromSelector(@selector(queryCache))];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder*)coder {
    self = [super init];
    if(self) {
        _queryCache =[coder decodeObjectOfClass:[NSMutableDictionary class]
                                         forKey:NSStringFromSelector(@selector(queryCache))];
    }
    return self;
}



#pragma mark - Main Behaviors

- (NSDictionary* _Nullable)cacheEntryForReference:(NSFetchRequest* _Nonnull)queryReference
                                             error:(NSError* _Nullable __autoreleasing * _Nullable)error
{
    NSDictionary* cacheEntry = nil;
    
    if (queryReference == nil) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:VDSKitErrorDomain
                                         code:VDSUnexpectedNilArgument
                                     userInfo:@{VDSArgumentCanNotBeNilErrorKey:VDS_NIL_ARGUMENT_MESSAGE(@"queryReference", _cmd)}];
        }
    } else {
        cacheEntry = [_queryCache objectForKey:queryReference];
    }
    
    return cacheEntry;
}

- (BOOL)setCacheEntry:(NSDictionary* _Nonnull)entry
         forReference:(NSFetchRequest* _Nonnull)queryReference
                error:(NSError* _Nullable __autoreleasing * _Nullable)error
{
    BOOL success = NO;
    
    if (queryReference == nil) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:VDSKitErrorDomain
                                         code:VDSUnexpectedNilArgument
                                     userInfo:@{VDSArgumentCanNotBeNilErrorKey:VDS_NIL_ARGUMENT_MESSAGE(@"queryReference", _cmd)}];
        }
    } else if (entry == nil) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:VDSKitErrorDomain
                                         code:VDSUnexpectedNilArgument
                                     userInfo:@{VDSArgumentCanNotBeNilErrorKey:VDS_NIL_ARGUMENT_MESSAGE(@"entry", _cmd)}];
        }
    } else {
        [_queryCache setObject:entry
                        forKey:queryReference];
    }
    
    return success;
}

#pragma mark - Utility Behaviors

#pragma mark Fast Enumeration

- (NSUInteger)countByEnumeratingWithState:(nonnull NSFastEnumerationState *)state
                                  objects:(__unsafe_unretained id  _Nullable * _Nonnull)buffer
                                    count:(NSUInteger)len {
    return [_queryCache countByEnumeratingWithState:state
                                     objects:buffer
                                       count:len];
}

#pragma mark NSCache Delegate

- (void)cache:(NSCache *)cache willEvictObject:(id)obj
{
    // Scan through a structure that lets me determine if this should be kept.
    [_absentCacheObjects addObject:obj];
}

@end



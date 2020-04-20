//
//  VDSDatabase.h
//  VDSKit
//
//  Created by Erikheath Thomas on 4/16/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDSQueryCache.h"
#import "VDSSnapshotCache.h"
#import "VDSEntityCache.h"


@interface VDSDatabase : NSObject {
    
    // For subclass reference only
    @private
    VDSQueryCache* _queryCache;
    VDSSnapshotCache* _snapshots;
    VDSEntityCache* _entityCache;
    
}

- (NSDictionary * _Nullable)cacheEntryForQueryReference:(NSString * _Nonnull)queryReference
                                                  error:(NSError * _Nullable __autoreleasing * _Nullable)error;

- (NSDictionary * _Nullable)rowForSnapshotID:(NSString * _Nonnull)snapshotID
                                       error:(NSError * _Nullable __autoreleasing * _Nullable)error;

- (NSArray * _Nullable)rowIDsForEntityName:(NSString * _Nonnull)entityName
                                     error:(NSError * _Nullable __autoreleasing * _Nullable)error;


@end


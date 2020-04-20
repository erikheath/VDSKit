//
//  VDSQueryCache.h
//  VDSKit
//
//  Created by Erikheath Thomas on 4/17/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>



NS_ASSUME_NONNULL_BEGIN

@interface VDSQueryCache : NSObject <NSSecureCoding, NSFastEnumeration, NSCacheDelegate> {
    @private
    NSMutableDictionary* _queryCache;
}

- (NSDictionary* _Nullable)cacheEntryForReference:(NSFetchRequest* _Nonnull)queryReference
                                             error:(NSError* _Nullable __autoreleasing * _Nullable)error;



@end

NS_ASSUME_NONNULL_END

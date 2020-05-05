//
//  VDSDatabase.m
//  VDSKit
//
//  Created by Erikheath Thomas on 4/16/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import "VDSDatabase.h"

@interface VDSDatabase ()

@property(strong, readonly, nonnull) VDSQueryCache* queryCache;
/* {key(query representation) : { key(timestamp) : value(timestamp);
                                  key(UUID) : value(UUID);
                                  key(entity) : value(name);
                                  key(rows) : value( [rowID] )
   }
 */

@property(strong, readonly, nonnull) VDSSnapshotCache* snapshots;
/* {key(entity) : { key(rowID) : value( { key(property name) : value(value);
                                          key(timestamp) : value(timestamp)
                                        })
                  }
  }
*/

@property(strong, readonly, nonnull) VDSEntityCache* entityCache;
/* {key(entity) : { key(rows) : value( [rowID] )
                  }
   }
*/

@end

@implementation VDSDatabase

- (instancetype)init
{
    self = [super init];
    if (self) {
        _queryCache = [VDSQueryCache new];
        _snapshots = [VDSSnapshotCache new];
        _entityCache = [VDSEntityCache new];
    }
    return self;
}



@end

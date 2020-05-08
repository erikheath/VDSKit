//
//  VDSEvictionOperation.h
//  VDSKit
//
//  Created by Erikheath Thomas on 5/7/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import "VDSOperation.h"

#pragma mark - VDSEvictionOperation -

/// VDSEvictionOperation is used by a VDSDatabase cache to process expired object
/// evictions from the cache store.
@interface VDSEvictionOperation : NSOperation

@end

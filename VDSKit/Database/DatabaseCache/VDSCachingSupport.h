//
//  VDSCachingSupport.h
//  VDSKit
//
//  Created by Erikheath Thomas on 5/24/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for VDSKit.
FOUNDATION_EXPORT double VDSCachingSupportVersionNumber;

//! Project version string for VDSKit.
FOUNDATION_EXPORT const unsigned char VDSCachingSupportVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <VDSCachingSupport/PublicHeader.h>

#import "VDSDatabaseCache.h"
#import "VDSDatabaseCacheDelegate.h"
#import "VDSDatabaseCacheConfiguration.h"
#import "VDSMutableDatabaseCacheConfiguration.h"
#import "VDSExpirableObject.h"
#import "VDSMergeableObject.h"

//
//  VDSErrorConstants.m
//  VDSKit
//
//  Created by Erikheath Thomas on 4/17/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import "VDSErrorConstants.h"


#pragma mark - VDSKit Core Errors

NSString* const VDSKitErrorDomain = @"VDSKitErrorDomain";


#pragma mark - VDSKit Cache Errors

VDSCacheErrorKey VDSCacheKeyCanNotBeNilErrorKey = @"VDSCacheKeyCanNotBeNilErrorKey";
VDSCacheErrorKey VDSCacheArgumentCanNotBeNilErrorKey = @"VDSCacheArgumentCanNotBeNilErrorKey";
 

VDSCacheErrorMessage VDSNilKeyErrorMessageFormat = @"The key for property %@ should not be nil. Try tracing the source of the key using the aggregated error report to determine where the nil key originates. Also, try placing a breakpoint for this accessor method: %@.";

VDSCacheErrorMessage VDSNilArgumentErrorMessageFormat = @"The argument %@ for method %@ may not be nil when querying the cache. Try tracing the source of the arguement using the aggregated error report to determine where the nil argument originates.";

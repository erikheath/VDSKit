//
//  VDSErrorConstants.h
//  VDSKit
//
//  Created by Erikheath Thomas on 4/17/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - VDSKit Core Errors

FOUNDATION_EXPORT NSString* const VDSKitErrorDomain;

typedef NS_ENUM(NSUInteger, VDSCacheErrorCode) {
    VDSEntryNotFound = 1,
    VDSUnexpectedNilArgument = 2,
};


#pragma mark - VDSKit Cache Errors

typedef NSString* const VDSCacheErrorKey;

FOUNDATION_EXPORT VDSCacheErrorKey VDSCacheKeyCanNotBeNilErrorKey;
FOUNDATION_EXPORT VDSCacheErrorKey VDSCacheArgumentCanNotBeNilErrorKey;

typedef NSString* const VDSCacheErrorMessage;

FOUNDATION_EXPORT VDSCacheErrorMessage VDSNilKeyErrorMessageFormat;

#ifndef VDS_NIL_KEY_MESSAGE
#define VDS_NIL_KEY_MESSAGE(ARGUMENT, METHOD) [NSString stringWithFormat:VDSNilKeyErrorMessageFormat, ARGUMENT, NSStringFromSelector(METHOD)]
#endif


FOUNDATION_EXPORT VDSCacheErrorMessage VDSNilArgumentErrorMessageFormat;

#ifndef VDS_NIL_ARGUMENT_MESSAGE
#define VDS_NIL_ARGUMENT_MESSAGE(ARGUMENT, METHOD) [NSString stringWithFormat:VDSNilArgumentErrorMessageFormat, ARGUMENT, NSStringFromSelector(METHOD)]
#endif

NS_ASSUME_NONNULL_END


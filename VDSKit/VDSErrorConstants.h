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
    VDSUnableToRemoveObject = 3,
};


#pragma mark - VDSKit Cache Errors -

typedef NSString* const VDSCacheErrorKey;

FOUNDATION_EXPORT VDSCacheErrorKey VDSCacheKeyCanNotBeNilErrorKey;
FOUNDATION_EXPORT VDSCacheErrorKey VDSCacheArgumentCanNotBeNilErrorKey;
FOUNDATION_EXPORT VDSCacheErrorKey VDSCacheObjectInUseErrorKey;

typedef NSString* const VDSCacheErrorMessage;

FOUNDATION_EXPORT VDSCacheErrorMessage VDSNilKeyErrorMessageFormat;

#ifndef VDS_NIL_KEY_MESSAGE
#define VDS_NIL_KEY_MESSAGE(ARGUMENT, METHOD) [NSString stringWithFormat:VDSNilKeyErrorMessageFormat, ARGUMENT, NSStringFromSelector(METHOD)]
#endif


FOUNDATION_EXPORT VDSCacheErrorMessage VDSNilArgumentErrorMessageFormat;

#ifndef VDS_NIL_ARGUMENT_MESSAGE
#define VDS_NIL_ARGUMENT_MESSAGE(ARGUMENT, METHOD) [NSString stringWithFormat:VDSNilArgumentErrorMessageFormat, ARGUMENT, NSStringFromSelector(METHOD)]
#endif

FOUNDATION_EXPORT VDSCacheErrorMessage VDSObjectInUseErrorMessageFormat;

#ifndef VDS_OBJECT_IN_USE_MESSAGE
#define VDS_OBJECT_IN_USE_MESSAGE(OBJECT, KEY) [NSString stringWithFormat:VDSObjectInUseErrorMessageFormat, OBJECT, KEY]
#endif


#pragma mark - VDSOperationErrors -

typedef NS_ENUM(NSUInteger, VDSOperationErrorCode) {
    VDSOperationConditionFailed,
    VDSOperationExecutionFailed,
    VDSOperationEnqueFailed,
};

typedef NSString* const VDSOperationErrorKey;

FOUNDATION_EXPORT VDSOperationErrorKey VDSOperationCouldNotEnqueueErrorKey;

typedef NSString* const VDSOperationErrorMessage;

FOUNDATION_EXPORT VDSOperationErrorMessage VDSQueueDelegateBlockedEnquementErrorMessageFormat;

#ifndef VDS_QUEUE_DELEGATE_BLOCKED_ENQUEMENT_MESSAGE
#define VDS_QUEUE_DELEGATE_BLOCKED_ENQUEMENT_MESSAGE(OPERATION_IDENTIFIER, QUEUE_IDENTIFIER) [NSString stringWithFormat:VDSQueueDelegateBlockedEnquementErrorMessageFormat, OPERATION_IDENTIFIER, QUEUE_IDENTIFIER]
#endif


NS_ASSUME_NONNULL_END


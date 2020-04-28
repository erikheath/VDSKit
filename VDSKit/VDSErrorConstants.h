//
//  VDSErrorConstants.h
//  VDSKit
//
//  Created by Erikheath Thomas on 4/17/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//


/*
 Error Management in VDSKit
 
 ***********************
 Error Handling Overview
 ***********************
 
 
 Error Reporting *****************
 
 VDSKit makes liberal use of error reporting and error chaining to provide
 consistent, informative, and timely feedback for developers, and where appropriate,
 for end users. To accomplish this, VDSKit follows three general patterns for error
 reporting:
 
 1. Most methods accept the address of an error pointer that can be set to
    point to a valid error object when one occurs.
 
 2. Methods that accept an error pointer address return a BOOL value to
    indicate whether the message sender should check for an error.
 
 3. For those classes that suport error logging, methods use a consistent naming
    convention to indicate if an error will be recorded internally as well as be
    reported, or if it will only be reported to the sender.
 
    Methods beginning with 'can', 'add', 'set', or 'remove' do not record to an
    object or class's internal error log. Note however, that methods called
    internally by 'can', 'add', 'set', or 'remove' methods may log errors to a
    class or object's internal error log.
 
    All other methods that accept an error pointer will generally log an error
    as well as report it to the sender. Methods that vary from this pattern
    are documented as doing so with the underlying rationale.
 
 4. Some methods do not accept an error pointer, but instead provide other
    means of determining if an error has occurred. This is generaly the case
    with methods whose interals are executed asynchronously. In these cases,
    either a delegate will be called with an error object or a completion
    handler can be provided that will receive an error object if an error
    occurs. In either case, for classes or objects that log errors, the
    error will be logged internally as indicated by the preceding rule(s).
 

 Error Chaining *****************

 In addition to error reporting, VDSKit makes use of error chaining when reporting
 errors. Error chaining links a series of errors together using NSErrors userInfo
 property with the NSUnderlyingError key associated with an error object that underlies
 the main error.
 
 Because error chaining occurs when multiple errors happen as the result of
 a method executing, a chain can often be matched to a call stack, enabling much
 faster error resolution. To make error chaining easier to use, VDSKit errors
 include more information than is typical in most frameworks. This includes:
 
 1. Error Location: The selector name is included to identify where in a call stack
    an error originated. Use the key VDSLocationErrorKey.
 
 2. Parameter Value Descriptions: For each argument submitted to the method, the
    parameter name and description for objects or values for non objects is included
    with the error. Use the key VDSLocationParametersErrorKey.
 
 3. Error Domain: For VDSKit, this is the VDSKitErrorDomain.
 
 4. Error Code: VDSKit provides a number of error codes that indicate the actual cause
    of the error. For example, a nil argument was encountered where a non-nil argument
    was expected.
 
 5. VDSKit Subsystem Error Key: VDSKit provides a number of error keys that correspond
    to its subsystems such as VDSOperationErrorKey and VDSCacheErrorKey. These error
    keys provide an interpretation of the cause of the error within the context of the
    subsystem and the method. Where possible, a recovery suggestion is provided. This
    suggestion is not appropriate for end users as it represents an internal diagnostic.
    This value is repeated using the NSDebugDescriptionErrorKey for convenience.
 
 6. Multiple Errors Report: In the event that multiple errors occur on multiple threads
    as part of a method's execution, VDSKit reports the individual errors using the
    VDSMultipleErrorsReportErrorKey with an array of the error objects. For this type of error,
    the NSUnderlyingErrorsKey is not included in the userInfo dictionary.
 
 Where possible, additional standard Cocoa Error keys are used to provide as rich a
 diagnostic report as possible. Methods that produce user facing error messages are
 documented as doing so.
 
 *************************************************
 Nil, Exceptions, and Unexpected Argument Handling
 *************************************************
 
 All VDSKit methods are annotated for nullability and in, out, and inout pointer semantics. However,
 sending a nil argument to a method in the Objective-C version of VDSKit will not cause an exception
 to be thrown or program termination. Instead, VDS methods employ a check at the beginning of method
 execution to determine if parameter arguments meet minimum conditions for execution including
 nullability, bounds, and in certain cases type. This argument checking is only done on public facing
 methods, so the additional overhead is minimal while providing important diagnostic details and helping
 to prevent inconsistent application states due to partial method execution.
 
 
 How It Works Internally *****************
 
 (Almost) All VDSKit methods begin with a BOOL success parameter whose value determines whether the
 method may execute or not. This success parameter's value is initially determined by assessing whether
 incoming arguments meet the minimum requirements for the method to execute. If arguments fail to meet
 the requirements, success is set to NO, the main body of the method is prevented from executing, the
 method will set an error if possible describing the failure, and finally will return NO to the sender.
 
 While not recommended, this behavior can be turned off using an environment setting: VDS_ARG_CHECKS and
 setting it to NO.
 
 
 Dealing With Exceptions *****************
 
 VDSKit does not generate exceptions. The reasons for this are that most errors in VDSKit are going to
 happen not because of programmer error (which should generate exceptions and be fixed), but because
 VDSKit is operating in a dynamic environment, often collecting data from unreliable sources over
 unreliable networks. Using errors enables VDSKit and anything built on top of it to treat this situation
 as a natural and expected alternate flow of events. This alternate flow will often result in
 in nil values being passed to parameters that expect non-nil values and is why VDSKit checks
 incoming argument values and returns errors instead of throwing nil argument exceptions.
 
 However, while VDSKit doesn't throw exceptions, most of the Cocoa systems that VDSKit builds on top of do.
 Because of this, where an exception is considered to be part of a normal operation, VDSKit will wrap
 exceptions in Error objects and foward them to a sender. Unexpected exceptions, for example trying to
 insert a nil into an array are not wrapped and will typically result in a program crash.
 
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - VDSKit Core Errors

FOUNDATION_EXPORT NSString* const VDSKitErrorDomain;

typedef NS_ENUM(NSUInteger, VDSKitErrorCode) {
    VDSUnknownError = 1, // The cause of the error is unknown.
    VDSMultipleErrors = 2, // Multiple errors have occurred, often simultaneously.
    VDSUnexpectedNilArgument = 3, // A nil argument was recived when non-nil was expected.
};

typedef NSString* const VDSCoreErrorKey;

FOUNDATION_EXPORT VDSCoreErrorKey VDSMultipleErrorsReportErrorKey; // A key for accessing multiple underlying errors.
FOUNDATION_EXPORT VDSCoreErrorKey VDSLocationErrorKey; // The selector name where the error occurred.
FOUNDATION_EXPORT VDSCoreErrorKey VDSLocationParametersErrorKey; // Parameter names and value descriptions.
FOUNDATION_EXPORT VDSCoreErrorKey VDSKeyCanNotBeNilErrorKey; // Key can not be nil.
FOUNDATION_EXPORT VDSCoreErrorKey VDSArgumentCanNotBeNilErrorKey; // Selector argument can not be nil.

typedef NSString* const VDSCoreErrorMessage;


FOUNDATION_EXPORT VDSCoreErrorMessage VDSNilKeyErrorMessageFormat;

#ifndef VDS_NIL_KEY_MESSAGE
#define VDS_NIL_KEY_MESSAGE(ARGUMENT, METHOD) [NSString stringWithFormat:VDSNilKeyErrorMessageFormat, ARGUMENT, NSStringFromSelector(METHOD)]
#endif


FOUNDATION_EXPORT VDSCoreErrorMessage VDSNilArgumentErrorMessageFormat;

#ifndef VDS_NIL_ARGUMENT_MESSAGE
#define VDS_NIL_ARGUMENT_MESSAGE(ARGUMENT, METHOD) [NSString stringWithFormat:VDSNilArgumentErrorMessageFormat, ARGUMENT, NSStringFromSelector(METHOD)]
#endif

#pragma mark - VDSKit Cache Errors -

typedef NS_ENUM(NSUInteger, VDSCacheErrorCode) {
    VDSEntryNotFound = 1, // The entry was not found in the cache.
    VDSUnableToRemoveObject = 2, // The entry could not be removed from the cache.
};


typedef NSString* const VDSCacheErrorKey;


FOUNDATION_EXPORT VDSCacheErrorKey VDSCacheObjectInUseErrorKey;

typedef NSString* const VDSCacheErrorMessage;


FOUNDATION_EXPORT VDSCacheErrorMessage VDSObjectInUseErrorMessageFormat;

#ifndef VDS_OBJECT_IN_USE_MESSAGE
#define VDS_OBJECT_IN_USE_MESSAGE(OBJECT, KEY) [NSString stringWithFormat:VDSObjectInUseErrorMessageFormat, OBJECT, KEY]
#endif


#pragma mark - VDSOperationErrors -

typedef NS_ENUM(NSUInteger, VDSOperationErrorCode) {
    VDSOperationConditionFailed,
    VDSOperationExecutionFailed,
    VDSOperationEnqueFailed,
    VDSOperationModificationFailed,
};

typedef NSString* const VDSOperationErrorKey;

FOUNDATION_EXPORT VDSOperationErrorKey VDSOperationCouldNotEnqueueErrorKey;
FOUNDATION_EXPORT VDSOperationErrorKey VDSOperationCouldNotModifyOperationErrorKey;
FOUNDATION_EXPORT VDSOperationErrorKey VDSOperationInvalidStateErrorKey;
FOUNDATION_EXPORT VDSOperationErrorKey VDSOperationFailedConditionErrorKey;

typedef NSString* const VDSOperationErrorMessage;

FOUNDATION_EXPORT VDSOperationErrorMessage VDSQueueDelegateBlockedEnquementErrorMessageFormat;

#ifndef VDS_QUEUE_DELEGATE_BLOCKED_ENQUEMENT_MESSAGE
#define VDS_QUEUE_DELEGATE_BLOCKED_ENQUEMENT_MESSAGE(OPERATION_IDENTIFIER, QUEUE_IDENTIFIER) [NSString stringWithFormat:VDSQueueDelegateBlockedEnquementErrorMessageFormat, OPERATION_IDENTIFIER, QUEUE_IDENTIFIER]
#endif


FOUNDATION_EXPORT VDSOperationErrorMessage VDSOperationCouldNotAddObserverErrorMessageFormat;

#ifndef VDS_OPERATION_COULD_NOT_ADD_OBSERVER_MESSAGE
#define VDS_OPERATION_COULD_NOT_ADD_OBSERVER_MESSAGE(OPERATION_IDENTIFIER, OBSERVER_IDENTIFIER) [NSString stringWithFormat:VDSOperationCouldNotAddObserverErrorMessageFormat, OPERATION_IDENTIFIER, OBSERVER_IDENTIFIER]
#endif


FOUNDATION_EXPORT VDSOperationErrorMessage VDSOperationCouldNotRemoveObserverErrorMessageFormat;

#ifndef VDS_OPERATION_COULD_NOT_REMOVE_OBSERVER_MESSAGE
#define VDS_OPERATION_COULD_NOT_REMOVE_OBSERVER_MESSAGE(OPERATION_IDENTIFIER, OBSERVER_IDENTIFIER) [NSString stringWithFormat:VDSOperationCouldNotRemoveObserverErrorMessageFormat, OPERATION_IDENTIFIER, OBSERVER_IDENTIFIER]
#endif


FOUNDATION_EXPORT VDSOperationErrorMessage VDSOperationCouldNotAddConditionErrorMessageFormat;

#ifndef VDS_OPERATION_COULD_NOT_ADD_CONDITION_MESSAGE
#define VDS_OPERATION_COULD_NOT_ADD_CONDITION_MESSAGE(OPERATION_IDENTIFIER, CONDITION_IDENTIFIER) [NSString stringWithFormat:VDSOperationCouldNotAddConditionErrorMessageFormat, OPERATION_IDENTIFIER, CONDITION_IDENTIFIER]
#endif


FOUNDATION_EXPORT VDSOperationErrorMessage VDSOperationCouldNotRemoveConditionErrorMessageFormat;

#ifndef VDS_OPERATION_COULD_NOT_REMOVE_CONDITION_MESSAGE
#define VDS_OPERATION_COULD_NOT_REMOVE_CONDITION_MESSAGE(OPERATION_IDENTIFIER, CONDITION_IDENTIFIER) [NSString stringWithFormat:VDSOperationCouldNotRemoveConditionErrorMessageFormat, OPERATION_IDENTIFIER, CONDITION_IDENTIFIER]
#endif


FOUNDATION_EXPORT VDSOperationErrorMessage VDSOperationCouldNotAddDependencyErrorMessageFormat;

#ifndef VDS_OPERATION_COULD_NOT_ADD_DEPENDENCY_MESSAGE
#define VDS_OPERATION_COULD_NOT_ADD_DEPENDENCY_MESSAGE(OPERATION_IDENTIFIER, DEPENDENCY_IDENTIFIER) [NSString stringWithFormat:VDSOperationCouldNotAddDependencyErrorMessageFormat, OPERATION_IDENTIFIER, DEPENDENCY_IDENTIFIER]
#endif


FOUNDATION_EXPORT VDSOperationErrorMessage VDSOperationCouldNotExecuteOperationWithStateErrorMessageFormat;

#ifndef VDS_OPERATION_COULD_NOT_EXECUTE_OPERATION_WITH_STATE_MESSAGE
#define VDS_OPERATION_COULD_NOT_EXECUTE_OPERATION_WITH_STATE_MESSAGE(OPERATION_IDENTIFIER, STATE_IDENTIFIER) [NSString stringWithFormat:VDSOperationCouldNotExecuteOperationWithStateErrorMessageFormat, OPERATION_IDENTIFIER, STATE_IDENTIFIER]
#endif


FOUNDATION_EXPORT VDSOperationErrorMessage VDSOperationCouldNotEvaluateConditionsWithStateErrorMessageFormat;

#ifndef VDS_OPERATION_COULD_NOT_EVALUATE_CONDITIONS_WITH_STATE_MESSAGE
#define VDS_OPERATION_COULD_NOT_EVALUATE_CONDITIONS_WITH_STATE_MESSAGE(OPERATION_IDENTIFIER, STATE_IDENTIFIER) [NSString stringWithFormat:VDSOperationCouldNotEvaluateConditionsWithStateErrorMessageFormat, OPERATION_IDENTIFIER, STATE_IDENTIFIER]
#endif


FOUNDATION_EXPORT VDSOperationErrorMessage VDSOperationCouldNotTransitionToStateErrorMessageFormat;

#ifndef VDS_OPERATION_COULD_NOT_TRANSTION_TO_STATE_MESSAGE
#define VDS_OPERATION_COULD_NOT_TRANSTION_TO_STATE_MESSAGE(OPERATION_IDENTIFIER, CURRENT_STATE_IDENTIFIER, NEW_STATE_IDENTIFIER) [NSString stringWithFormat:VDSOperationCouldNotTransitionToStateErrorMessageFormat, OPERATION_IDENTIFIER, CURRENT_STATE_IDENTIFIER, NEW_STATE_IDENTIFIER]
#endif


FOUNDATION_EXPORT VDSOperationErrorMessage VDSOperationCouldNotSatisfyConditionErrorMessageFormat;

#ifndef VDS_OPERATION_COULD_NOT_SATISFY_CONDITION_MESSAGE
#define VDS_OPERATION_COULD_NOT_SATISFY_CONDITION_MESSAGE(OPERATION_IDENTIFIER, CONDITION_IDENTIFIER) [NSString stringWithFormat:VDSOperationCouldNotSatisfyConditionErrorMessageFormat, OPERATION_IDENTIFIER, CONDITION_IDENTIFIER]
#endif


NS_ASSUME_NONNULL_END


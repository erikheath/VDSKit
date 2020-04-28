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
VDSCacheErrorKey VDSCacheObjectInUseErrorKey = @"VDSCacheObjectInUseErrorKey";
 

VDSCacheErrorMessage VDSNilKeyErrorMessageFormat = @"The key for property %@ should not be nil. Try tracing the source of the key using the aggregated error report to determine where the nil key originates. Also, try placing a breakpoint for this accessor method: %@.";

VDSCacheErrorMessage VDSNilArgumentErrorMessageFormat = @"The argument %@ for method %@ may not be nil when querying the cache. Try tracing the source of the arguement using the aggregated error report to determine where the nil argument originates.";

VDSCacheErrorMessage VDSObjectInUseErrorMessageFormat = @"The object\n%@\n using key\n%@\ncan not be removed because it is in use by the cache. To remove the object, message the cache to remove the object from use, and then attempt removal again.";


#pragma mark - VDSKit Extended Operation Errors

VDSOperationErrorKey VDSOperationCouldNotEnqueueErrorKey = @"VDSOperationCouldNotEnqueueErrorKey";
VDSOperationErrorKey VDSOperationCouldNotModifyOperationErrorKey = @"VDSOperationCouldNotModifyOperationErrorKey";
VDSOperationErrorKey VDSOperationInvalidStateErrorKey = @"VDSOperationInvalidStateErrorKey";
VDSOperationErrorKey VDSOperationFailedConditionErrorKey = @"VDSOperationFailedConditionErrorKey";

VDSOperationErrorMessage VDSQueueDelegateBlockedEnquementErrorMessageFormat = @"The operation\n%@\nwas blocked from being added to the operation queue \n%@\n by the queue delegate.";

VDSOperationErrorMessage VDSOperationCouldNotAddObserverErrorMessageFormat = @"The operation\n%@\ncould not add the observer \n%@\nto its observers.";

VDSOperationErrorMessage VDSOperationCouldNotRemoveObserverErrorMessageFormat = @"The operation\n%@\ncould not remove the observer \n%@\nfrom its observers.";

VDSOperationErrorMessage VDSOperationCouldNotAddConditionErrorMessageFormat = @"The operation\n%@\ncould not add the condition \n%@\nto its conditions.";

VDSOperationErrorMessage VDSOperationCouldNotRemoveConditionErrorMessageFormat = @"The operation\n%@\ncould not remove the conditions \n%@\nfrom its conditions.";

VDSOperationErrorMessage VDSOperationCouldNotAddDependencyErrorMessageFormat = @"The operation\n%@\ncould not add the dependency \n%@\nto its dependencies.";

VDSOperationErrorMessage VDSOperationCouldNotExecuteOperationWithStateErrorMessageFormat = @"The operation\n%@\nwith state \n%d\ncould not be executed. Ensure that the opertion has been added to a compatible oeration queue and that its state equals VDSOperationReady(4).";

VDSOperationErrorMessage VDSOperationCouldNotEvaluateConditionsWithStateErrorMessageFormat = @"The operation\n%@\nwith state \n%d\ncould not evaluate conditions. Ensure that the opertion has been added to a compatible oeration queue, that its state equals VDSOperationPending(2), and that the operations has not been cancelled.";

VDSOperationErrorMessage VDSOperationCouldNotTransitionToStateErrorMessageFormat = @"The operation\n%@\nwith state \n%d\ncould not transition to new state\n%d\nEnsure that the opertion has been added to a compatible oeration queue, that its state precedes the desired new state, and that the operations has not been cancelled.";

VDSOperationErrorMessage VDSOperationCouldNotSatisfyConditionErrorMessageFormat = @"The operation\n%@\ncould not satisfy the  condition:\n%@\n";



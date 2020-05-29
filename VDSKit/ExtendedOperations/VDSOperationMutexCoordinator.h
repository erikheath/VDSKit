//
//  VDSOperationMutexCoordinator.h
//  VDSKit
//
//  Created by Erikheath Thomas on 5/6/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

@import Foundation;

#import "VDSOperation.h"





#pragma mark - VDSOperationMutexCoordinator -

/// @summary The VDSOperationMutexCoordinator provides a singleton that ensures
/// only one of a VDSOperation instance type may execute at a time. This
/// exclusivity occurs across VDSOperationQueues.
///
@interface VDSOperationMutexCoordinator : NSObject

#pragma mark - Properties

/// @summary The shared instance that should be used by the app.
///
@property(class, strong, readonly, nonnull) VDSOperationMutexCoordinator* sharedCoordinator;


#pragma mark - Configuration Behavior

/// @summary Adding an operation to the VDSOperationMutexCoordinator makes its exectuion
/// mutually exclusive across all VDSOperationQueue.
///
/// @param operation The operation that will be made mutally exclusive.
///
/// @param conditionTypes The conditions that require mutual exclusivity before this operation
/// can execute.
///
- (void)addOperation:(VDSOperation* _Nonnull)operation
  forConditionsTypes:(NSArray<NSString*>* _Nonnull)conditionTypes;


/// @summary Removing an operation from the VDSOperationMutexCoordinator removes its
/// execution from being mutually exclusive for the specified condition types.
///
/// @param operation The operation that should no longer be mutually exclusive.
///
/// @param conditionTypes The mutually exclusive conditions that the operation
/// will no longer require for execution.
///
- (void)removeOperation:(VDSOperation* _Nonnull)operation
      forConditionTypes:(NSArray<NSString*>* _Nonnull)conditionTypes;


@end

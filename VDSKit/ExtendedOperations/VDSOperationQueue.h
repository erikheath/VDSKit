//
//  VDSOperationQueue.h
//  VDSKit
//
//  Created by Erikheath Thomas on 4/22/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//
//
//
// This code is directly inspired by sample code provided by Apple Inc.
// at the 2015 WWDC for its WWDC Swift sample app. It has been ported to
// Objective-C and altered for use within VDSKit.
//
//
//
//
//

#import <Foundation/Foundation.h>
#import "VDSOperation.h"

@class VDSOperationQueue;


#pragma mark - VDSOperationMutexCoordinator -


/// The VDSOperationMutexCoordinator provides a singleton that ensure
/// only one of a VDSOperation instance type may execute at a time. This
/// exclusivity occurs across VDSOperationQueues.
@interface VDSOperationMutexCoordinator : NSObject

/// The shared instance that should be used by the app.
@property(class, strong, readonly, nonnull) VDSOperationMutexCoordinator* sharedCoordinator;

/// Adding an operation to the VDSOperationMutexCoordinator makes its exectuion
/// mutually exclusive across all VDSOperationQueue.
/// @param operation The object that will be made mutally exclusive.
/// @param conditionTypes The conditions that require mutual exclusivity before this operation
/// can execute.
- (void)addOperation:(VDSOperation* _Nonnull)operation
  forConditionsTypes:(NSArray<NSString*>* _Nonnull)conditionTypes;

/// Removing an operation from the VDSOperationMutexCoordinator removes its
/// execution from being mutually exclusive for the specified condition types.
/// @param operation The operation that should no longer be mutually exclusive.
/// @param conditionTypes The mutually exclusive conditions that the operation
/// will no longer require for execution.
- (void)removeOperation:(VDSOperation* _Nonnull)operation
      forConditionTypes:(NSArray<NSString*>* _Nonnull)conditionTypes;

@end

@protocol VDSOperationQueueDelegate <NSObject>

/// In some cases, operations may need to be filtered from a queue. For
/// example, if a queue only accepts a certain number of a type of operation,
/// this method can be used to prevent more than a certain number of an
/// operation type from being added to a queue at any one time. As an
/// alternative, operations can be capture and coalesced so that
/// only the most recent is executed at any time.
/// @param queue The queue to which the operation is to be added.
/// @param operation The operation to be added to the queue.
- (BOOL)operationQueue:(VDSOperationQueue* _Nonnull)queue
    shouldAddOperation:(VDSOperation* _Nonnull)operation;

/// Notifies the delegate that the operation queue will add
/// an operation. Use this method for any additional configuration
/// of the operation.
/// @param queue The queue to which the operation will be added.
/// @param operation The operation that will be added.
- (void)operationQueue:(VDSOperationQueue* _Nonnull)queue
      willAddOperation:(VDSOperation* _Nonnull)operation;

/// Notifies the delegate that the operation queue added an
/// operation to its queue.
/// @param queue The queue to which the operation was added.
/// @param operation The operation that was added to the queue.
- (void)operationQueue:(VDSOperationQueue* _Nonnull)queue
       didAddOperation:(VDSOperation* _Nonnull)operation;

/// Notifies the delegate that an operation on the queue finished,
/// reporting any errors if they occurred.
/// @param queue The queue on which the operation executed.
/// @param operation The operation that finished.
- (void)operationQueue:(VDSOperationQueue* _Nonnull)queue
    operationDidFinish:(VDSOperation* _Nonnull)operation;
@end


#pragma mark - VDSOperationQueue -

/// An NSOperationQueue subclass that adds delegation and convenience
/// features for working with VDSOperation.
@interface VDSOperationQueue : NSOperationQueue <VDSOperationDelegate>

/// An object that implements the VDSOperationQueueDelegate protocol.
@property(weak, readwrite, nullable) id<VDSOperationQueueDelegate> delegate;

/// Attempts to add the operation to the queue.
/// @param operation The operation that should be added to the queue.
/// @param error An error object describing the error. Use the return value to know when
/// to check for an error object. A return value of NO will always produce an error object.
///
/// @returns YES if the operation could be added, otherwise NO.
- (BOOL)addOperation:(VDSOperation* _Nonnull)operation
               error:(NSError* __autoreleasing _Nullable * _Nullable)error;

/// This method calls addOperation:error for each operation in the array, and coalesces any errors
/// that occur into a single error object. If an error occurs, any operations that have been
/// added are removed if possible.
/// @param operations The operations that should be added to the queue.
/// @param error An error object describing the error. Use the return value to know when
/// to check for an error object. A return value of NO will always produce an error object.
///
/// @returns YES if the operations could be added, otherwise NO.
- (BOOL)addOperations:(NSArray<VDSOperation*>* _Nonnull)operations
                error:(NSError* __autoreleasing _Nullable * _Nullable)error;


@end


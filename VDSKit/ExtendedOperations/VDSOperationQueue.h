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

@import Foundation;

#import "VDSOperation.h"
#import "VDSOperationDelegate.h"


@class VDSOperationQueue;
@class VDSOperationMutexCoordinator;





#pragma mark - VDSOperationQueueDelegate -


/// @summary VDSOperationQueueDelegate provides an interface for customizing
/// the behavior of an operation queue.
///
/// @discussion VDSOperationQueueDelegate provides behavior customization
/// control points when adding an operation and when an operation completes
/// its execution. The queue delegates primary purpose is to provide more
/// granular control over what operations get added to the queue, enabling
/// delegates to block the addition of operations and to keep track of
/// when an operation is added.
///
/// The queue also notifies its delegate when an opertion is complete,
/// enabling the queue to act as a trigger point for clean up
/// or other asynchronous behavior.
///
@protocol VDSOperationQueueDelegate <NSObject>

@optional

///@summary Asks the delegate if the operation should be added to the queue.
///
/// @discussion In some cases, operations may need to be filtered from a queue. For
/// example, if a queue only accepts a certain number of a type of operation,
/// this method can be used to prevent more than a certain number of an
/// operation type from being added to a queue at any one time. As an
/// alternative, operations can be captured and coalesced so that
/// only the most recent is executed at any time.
///
/// @param queue The queue to which the operation is to be added.
///
/// @param operation The operation to be added to the queue.
///
- (BOOL)operationQueue:(VDSOperationQueue* _Nonnull)queue
    shouldAddOperation:(NSOperation* _Nonnull)operation;


/// Notifies the delegate that the operation queue will add
/// an operation. Use this method for any additional configuration
/// of the operation.
///
/// @param queue The queue to which the operation will be added.
///
/// @param operation The operation that will be added.
///
- (void)operationQueue:(VDSOperationQueue* _Nonnull)queue
      willAddOperation:(NSOperation* _Nonnull)operation;


/// Notifies the delegate that an operation on the queue finished.
///
/// @param queue The queue on which the operation executed.
///
/// @param operation The operation that finished.
///
- (void)operationQueue:(VDSOperationQueue* _Nonnull)queue
    operationDidFinish:(NSOperation* _Nonnull)operation;


@end





#pragma mark - VDSOperationQueue -

/// @summary VDSOperationQueue is a NSOperationQueue subclass that
/// adds delegation and convenience features for working with VDSOperation.
///
/// @discussion VDSOperationQueue is responsible for the setup of VDSOperation
/// instances and subclass instances. When enqueueing an instance, the queue
/// processes the conditions and observers associated with the instance. Once
/// conditions and observers are configured, the instance is enqueued, and
/// executes as it would on a regular NSOperationQueue.
///
@interface VDSOperationQueue : NSOperationQueue <VDSOperationDelegate>


#pragma mark Properties

/// @summary An object that implements the VDSOperationQueueDelegate protocol.
/// The delegate can alter the behavior of adding operations and is notified
/// of operation completion.
///
@property(weak, readwrite, nullable) id<VDSOperationQueueDelegate> delegate;


#pragma mark Extended Behaviors

/// @summary Attempts to add the operation to the queue.
///
/// @discussion -(void)addOperation: is an override of NSOperation's instance
/// method of the same name, and provides additional configuration for operation
/// instances, including setting itself as the operation's delegate and
/// creating a callback to notify itself when an operation has completed.
///
/// @param operation The operation that should be added to the queue.
///
/// @throws NSInternalInconsistency exception if operations is nil or of the wrong type.
/// To prevent this behavior, define NS_BLOCK_ASSERTIONS.
///
- (void)addOperation:(NSOperation* _Nonnull)operation;


/// @summary This method calls addOperation: for each operation in the passed inarray.
///
/// @discussion See -(void)addOperation: for more details.
///
/// @param operations The operations that should be added to the queue.
///
/// @throws NSInternalInconsistency exception if operations are of the wrong type.
/// To prevent this behavior, define NS_BLOCK_ASSERTIONS.
///
- (void)addOperations:(NSArray<NSOperation*>* _Nonnull)operations;


@end


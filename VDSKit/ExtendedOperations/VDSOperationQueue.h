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
#import "VDSOperationDelegate.h"


@class VDSOperationQueue;
@class VDSOperationMutexCoordinator;



@protocol VDSOperationQueueDelegate <NSObject>

/// In some cases, operations may need to be filtered from a queue. For
/// example, if a queue only accepts a certain number of a type of operation,
/// this method can be used to prevent more than a certain number of an
/// operation type from being added to a queue at any one time. As an
/// alternative, operations can be captured and coalesced so that
/// only the most recent is executed at any time.
/// @param queue The queue to which the operation is to be added.
/// @param operation The operation to be added to the queue.
- (BOOL)operationQueue:(VDSOperationQueue* _Nonnull)queue
    shouldAddOperation:(NSOperation* _Nonnull)operation;

/// Notifies the delegate that the operation queue will add
/// an operation. Use this method for any additional configuration
/// of the operation.
/// @param queue The queue to which the operation will be added.
/// @param operation The operation that will be added.
- (void)operationQueue:(VDSOperationQueue* _Nonnull)queue
      willAddOperation:(NSOperation* _Nonnull)operation;

/// Notifies the delegate that an operation on the queue finished,
/// reporting any errors if they occurred.
/// @param queue The queue on which the operation executed.
/// @param operation The operation that finished.
- (void)operationQueue:(VDSOperationQueue* _Nonnull)queue
    operationDidFinish:(NSOperation* _Nonnull)operation;
@end


#pragma mark - VDSOperationQueue -

/// An NSOperationQueue subclass that adds delegation and convenience
/// features for working with VDSOperation.
@interface VDSOperationQueue : NSOperationQueue <VDSOperationDelegate>

/// An object that implements the VDSOperationQueueDelegate protocol.
@property(weak, readwrite, nullable) id<VDSOperationQueueDelegate> delegate;

/// Attempts to add the operation to the queue.
/// @param operation The operation that should be added to the queue.
///
/// @throws NSInternalInconsistency exception if operations is nil or of the wrong type.
- (void)addOperation:(NSOperation* _Nonnull)operation;

/// This method calls addOperation:error for each operation in the array, and coalesces any errors
/// that occur into a single error object. If an error occurs, any operations that have been
/// added are removed if possible.
/// @param operations The operations that should be added to the queue.
///
/// @throws NSInternalInconsistency exception if operations is nil.
- (void)addOperations:(NSArray<NSOperation*>* _Nonnull)operations;


@end


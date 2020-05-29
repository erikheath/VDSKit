//
//  VDSGroupOperation.h
//  VDSKit
//
//  Created by Erikheath Thomas on 4/30/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import "VDSOperation.h"
#import "VDSOperationQueue.h"





#pragma mark - VDSGroupOperation -

/// @summary VDSGroupOperation provides a mechanism for grouping and controling
/// the execution of child operations as part of a parent operation's
/// execution.
///
/// @discussion Use VDSGroupOperation to organize the execution of a series of
/// subtasks for a larger task (the group operation). Organizing operations using
/// group operations simplifies dependency management where a series of subtasks
/// may execute independently but must all complete before considering a larger task
/// to be complete.
///
/// Group operations also provide a means of generating multiple operations for
/// a condition dependency. Conditions may only define a single operation as a
/// dependency. However, if that dependency is define as a group operation, then
/// the group operation may be defined to produce one or more subtasks (operations),
/// effectively enabling a condition to have multiple operation dependencies.
///
@interface VDSGroupOperation : VDSOperation <VDSOperationQueueDelegate>

#pragma mark - Properties

/// The VDSOperationQueue used by the group to manage and execute its operations. This
/// property provides access to the queue for additional operation control such as
/// pausing the queue, restarting the queue, canceling operations, etc.
///
@property(strong, readonly, nonnull) VDSOperationQueue* internalQueue;


#pragma mark - Object Lifecycle

/// @summary Convenience initializer that accepts a variable number of operation arguments
/// to add to the group operation.
///
/// @discussion Use this convenience initializer to create a group operation with a nil terminated
/// variable number of arguments. This method calls -(instancetype)initWithOperations: by wrapping
/// the passed in operations into an array.
///
/// @param operation Zero or more operations that should be added to the group operation.
///
/// @return An instance of VDSGroupOperation, or nil if an initialization error occurred.
///
/// @throws If the NS_BLOCK_ASSERTIONS macro is not defined, will throw
/// NSInternalInconsistency exception if operation is of the wrong type.
///
+ (instancetype _Nullable)initWithOperations:(NSOperation* _Nullable)operation, ...;


/// @summary Initializes a group operation with zero or more operations from a passed in array.
///
/// @discussion This is the designated initializer for creating group operations.
///
/// @param operations An array of zero or more NSOperation derived operations.
///
/// @return An instance of VDSGroupOperation, or nil if an initialization error occurred.
///
/// @throws If the NS_BLOCK_ASSERTIONS macro is not defined, will throw
/// NSInternalInconsistency exception if operation is of the wrong type.
///
- (instancetype _Nullable)initWithOperations:(NSArray<NSOperation*>* _Nullable)operations NS_DESIGNATED_INITIALIZER;


/// @summary Adds an operation to the group's internal queue.
///
/// @discussion This method should be used as the sole public access point for adding operations to
/// the group operation's internal queue. While operations can be added to the queue
/// using queue methods, doing so circumvents important checks for correct operation of
/// the group's internal queue.
///
/// @param operation An NSOperation derived operation to add to the group's internal queue.
///
/// @throws If the NS_BLOCK_ASSERTIONS macro is not defined, will throw
/// NSInternalInconsistency exception if operation is nil or of the wrong type.
///
- (void)addOperation:(NSOperation* _Nonnull)operation;


/// @summary Adds zero or more operations to the group's internal queue.
///
/// @discussion This method iterates through the operations array,
/// calling -(void)addOperation: for each operation in the passed in array.
///
/// @param operations An array of zero or more operations that should be
/// added to the group's queue.
///
/// @throws If the NS_BLOCK_ASSERTIONS macro is not defined, will throw
/// NSInternalInconsistency exception if operation is of the wrong type
/// or if operations array is nil.
///
- (void)addOperations:(NSArray<NSOperation*>* _Nonnull)operations;


/// @summary Called when an operation in the group's internal queue finishes.
///
/// @discussion Subclasses can use this method to determine when an operation
/// in the internal queue has completed it task and has entered into its
/// finishing work.
///
/// @param operation The operation in the group's intenal queue that has completed
/// its task.
///
- (void)operationDidFinish:(NSOperation* _Nonnull)operation;


@end


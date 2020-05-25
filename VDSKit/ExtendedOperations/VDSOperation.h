//
//  VDSOperation.h
//  VDSKit
//
//  Created by Erikheath Thomas on 5/6/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

@import Foundation;

#import "../VDSConstants.h"
#import "../VDSErrorConstants.h"


@class VDSOperationCondition;
@protocol VDSOperationObserver;
@protocol VDSOperationDelegate;





#pragma mark - NSOperation+VDSOperation -

/// The VDSOperation category on NSOperation adds a single method, -(void)addCompletionBlock:
/// that can be used by any NSOperation to add additional completion blocks. For
/// VDSOperationQueue, the method is used to add a notification to observers that the
/// operation has completed if the opertion is not a subclass of VDSOperation.
///
@interface NSOperation (VDSOperation)


/// @summary Adds a completion block to the operation. If a completion block exists, the
/// existing block is wrapped in a block that will execute the existing block first
/// followed by the new completion block.
///
/// @param completionBlock A completion block that will be executed after the operation
/// enters its finished state.
///
/// @throws NSInternalInconsistency exception if completionBlock is nil unless the
/// preprocessor macro NS_BLOCK_ASSERTIONS is defined.
///
- (void)addCompletionBlock:(void(^_Nonnull)(void))completionBlock;


@end





#pragma mark - VDSOperation -

/// @summary VDSOperation is the base class for extended operation support in VDSKit.
///
/// @discussion VDSOperation provides significant functionality including the ability to conditionalize
/// execution, to maintain and notify a list of observers when specific events happen before,
/// during, and after execution, to keep track of errors during execution, and to enable behavior
/// cutomization using a delegate. In addition, it enables subclasses to customize both
/// exeuction behavior and finishing behavior which enables a more granular approach to
/// desinging an operation.
///
/// @note VDSOperation is designed to be used only on a VDSOperationQueue as certain aspects of its
/// execution require set up provided by the that specific type of operation queue.
///
@interface VDSOperation : NSOperation


#pragma mark Properties

/// Indicates that the operation has received a message that it has been added
/// to a queue and should not accept additional conditions or observers.
///
@property(readonly) BOOL enqueued;
 

/// The conditions the operation must satisfy before it executes.
///
@property(strong, readonly, nonnull) NSArray<VDSOperationCondition*>* conditions;


/// @summary The observers that have registed for a subset of delegate notifications.
///
@property(strong, readonly, nonnull) NSArray<id<VDSOperationObserver>>* observers;


/// @summary Upon completion, contains the errors, if any, reported during execution of the
/// operation. During execution, the array is updated as errors occur.
///
/// This property is Key-Value Observable.
///
@property(strong, readonly, nonnull) NSArray<NSError*>* errors;


/// @summary An object conforming to the VDSOperationDelegate protocol. The operation
/// delegate has the opportunity to both monitor, alter, and prevent the operation
/// from taking certain actions before, during, and after execution.
///
@property(weak, readwrite, nullable) id<VDSOperationDelegate> delegate;


#pragma mark  Configuration Behaviors

/// @summary Adds a VDSOperationCondition to the operation.
///
/// @param condition The condition that should be added to the Operation.
///
/// @warning It is an error to attempt adding a condition once an operation is
/// added to a queue.
///
/// @throws If the NS_BLOCK_ASSERTIONS macro is not defined, will throw
/// NSInternalInconsistency exception if condition is nil, of the wrong type, or
/// could not be added due to operation state.
///
- (void)addCondition:(VDSOperationCondition* _Nonnull)condition;


/// @summary Adds an observer, typically another operation, to the receiver.
///
/// @note Anonymous observers can be added using a VDSBlockObserver instance. These objects
/// enable you to add functionality to the operation without having to subclass
/// it. Block observers are the right option when the additional functionality
/// is limited and subclassing would result in an object with little change or
/// that will only be used in a sigle scenario.
///
/// @param observer An object conforming to the VDSOperationObserver protocol.
///
/// @warning It is an error to attempt adding an observer once an operation is
/// added to a queue.
///
/// @throws If the NS_BLOCK_ASSERTIONS macro is not defined, will throw
/// NSInternalInconsistency exception if observer is nil, of the wrong type, or
/// could not be added due to operation state.
///
- (void)addObserver:(id<VDSOperationObserver> _Nonnull)observer;


/// Notifies the operation that it is about to be enqueued and its conditions
/// and observers will be processed. After receiving the willEnqueue message,
/// the state of the enqueued property changes to YES, and no additional conditions
/// or observers may be added to the operation.
- (void)willEnqueue;


#pragma mark Execution Behaviors

/// @summary Primary override point for subclasses to specialize a VDSOperation.
///
/// @discussion Subclasses must call -(void)finishWithErrors: once the
/// operation's task is done. This can be done in this method by calling the super
/// implementation of execute at the end of the execute method, by calling -(void)finishWithErrors:
/// directly in the subclass implementation of the execute method, or by calling
/// -(void)finishWithErrors: from some other method when the operation's task is complete.
///
- (void)execute;


/// Convenience method that can be called when an operation finishes with or without an error. Calls
/// finishWithErrors:.
///
/// @param error An error object describing the error if one occurred.
- (void)finish:(NSError* _Nullable)error;

/// @summary Called to finsish the execution of the operation's task and to notifiy the operation
/// and any interested parties that the main task of the operation has completed and the
/// operation is now in a finishing state.
///
/// @discussion This method calls finishing, the subclass override point.
///
/// @param errors An array containing error objects to be added to the operationErrors array.
- (void)finishWithErrors:(NSArray<NSError*>* _Nullable)errors;


/// @summary Override point for subclasses to add additional behavior during the finishing process.
///
/// @discussion This method is called by finishWithErrors: after all errors have been set on the object.
- (void)finishing;


/// @summary Cancels the operation and adds the error to the operationErrors array.
///
/// @param error An error object describing the error.
- (void)cancelWithError:(NSError* _Nullable)error;


@end


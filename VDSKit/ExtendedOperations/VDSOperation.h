//
//  VDSOperation.h
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
#import "../VDSConstants.h"
#import "../VDSErrorConstants.h"

@class VDSOperation;
@class VDSOperationCondition;
@class VDSOperationQueue;


#pragma mark - NSOperation+VDSOperation -

@interface NSOperation (VDSOperation)

- (void)addCompletionBlock:(void(^ _Nonnull)(void))block;

@end


#pragma mark - VDSOperationDelegate -

@protocol VDSOperationDelegate <NSObject>

@optional

/// @summary Notifies the delegate that the operation intends to
/// begin executing. This methods provides the delegate with the
/// opportunity to prevent the operation from executing, effectively
/// preventing its isReady state from becoming YES
/// @param operation The operation that intends to begin executing.
- (BOOL)operationShouldStart:(VDSOperation* _Nonnull)operation;

/// @summary Notifies the delegate that the operation will begin
/// executing.
///
/// @param operation The operation that will begin execution.
- (void)operationWillStart:(VDSOperation* _Nonnull)operation;

/// Notifies the delegate that the operation has started.
/// @param operation The operation that produced the new operation.
- (void)operationDidStart:(VDSOperation* _Nonnull)operation;

/// @summary Notifies the delegate that the operation intends to
/// produce a new operation for an operation, providing it with the
/// opportunity to prevent the production of the operation.
///
/// @discussion Instead of canceling the production of the operation,
/// the delegate can change the type of operation produced in the
/// operation:WillProduceOperation: method.
///
/// @param operation The operation that will produce the new operation.
/// @param newOperation The class of the new operation.
/// @returns YES if the operation should proceed to with producing
/// a new operation, NO otherwise.
- (BOOL)operation:(VDSOperation* _Nonnull)operation
    shouldProduceOperation:(Class _Nonnull)newOperation;

/// @summary Notifies the delegate that the opertion will produce a
/// new operation of the specified class. The delegate may return a
/// different class as a substitution.
///
/// @param operation The operation that will produce the new operation.
/// @param newOperation The class of the new operation.
///
/// @returns A class that should replace the class in question, typically
/// a VDSOperation.
- (Class _Nullable)opertion:(VDSOperation* _Nonnull)operation
    willProduceOperation:(Class _Nonnull)newOperation;

/// Notifies the delegate that the opertion produced a new operation
/// for its dependencies.
/// @param operation The operation that produced the new operation.
- (void)operation:(VDSOperation* _Nonnull)operation didProduceOperation:(VDSOperation* _Nonnull)newOperation;

/// Notifies the delegate that the operation is beginning the finishing stage of its
/// execution. This notification happens after the state of the operation moves
/// to VDSOperationFinishing but before the fishinedWithErrors method is called.
///
/// @param operation The operation that will finish executing.
- (void)operationWillFinish:(VDSOperation* _Nonnull)operation;

/// Notifies the delegate that the operation has finished executing. This method is called
/// once the state has moved to VDSOperationFinished, but before any completion handlers have
/// been called.
/// 
/// @param operation The operation that has finished executing.
- (void)operationDidFinish:(VDSOperation* _Nonnull)operation;


@end


#pragma mark - VDSOperationObserver -

@protocol VDSOperationObserver <NSObject>

/// Notifies the observer that the operation has started.
/// @param operation The operation that produced the new operation.
- (void)operationDidStart:(VDSOperation* _Nonnull)operation;

/// Notifies the observer that the opertion produced a new operation
/// for its dependencies.
/// @param operation The operation that produced the new operation.
/// @param newOperation The operation the was produced.
- (void)operation:(VDSOperation* _Nonnull)operation
    didProduceOperation:(NSOperation* _Nonnull)newOperation;

/// Notifies the observer that the operation has finished executing.
/// @param operation The operation that has finished executing.
- (void)operationDidFinish:(VDSOperation* _Nonnull)operation;

@end


#pragma mark - VDSOperationCondition -

@interface VDSOperationCondition : NSObject


/// @summary This class methods causes each condition to evaluate itself for the
/// operation. It aggregates the results, returning YES if all conditons were
/// satisfied, and NO if any of the conditons went unsatisfied. If a reference to an
/// error object is provided, this method aggregates all errors and provides them under
/// a single aggregation error using the NSUnderlyingErrorsKey within the userInfo dictionary
/// of the error.
///
/// @param operation The operation whose conditons need to be evaluated.
/// @param error An error aggregating any errors during evaluation. Use the return value to know when
/// to check for an error object. A return value of NO will always produce an error object.
///
/// @returns YES if the operation condition(s) was satisfied, otherwise NO.
+ (BOOL)evaluateConditionsForOperation:(VDSOperation* _Nonnull)operation
                                 error:(NSError* __autoreleasing _Nullable * _Nullable)error;

/// The name of the condition that will be used in error reporting.
@property(class, strong, readonly, nonnull) NSString* conditionName;

/// @summary YES if multiple instances of an operation may execute concurrently, NO if only
/// one instance of an operation may execute at any one time. This affects all
/// VDSOperation instances that are added to any VDSOperationQueue.
@property(class, readonly) BOOL isMutuallyExclusive;

/// @summary In many cases, a condition can be satisfied if a dependent operation is run
/// before the conditional operation is run. To accomplish this, a condition can
/// produce an operation that should be added to the conditional operation as a
/// dependency. When the conditional operation's dependencies are run, the condition
/// can be satisfied, enableing the conditional operation to successfully execute.
///
/// @note If multiple operations are needed that can not be automatically produced using
/// conditions, consider using a group operation to create a set of operations that can
/// be produced and run to satisfy the conditional operation.
///
/// @param operation The conditional operation.
/// @returns An operation than can be added to the conditional operation's dependencies
/// and that, when run, may satisfy the conditional operation's execution requirements.
- (VDSOperation* _Nullable)dependencyForOperation:(VDSOperation* _Nonnull)operation;

/// @summary This instance method is the override point that enables subclasses to insert
/// evaluation logic, error reporting, and a result for a given condition.
///
/// @param operation The operation whose conditions will be evaluated.
/// @param error An error object describing the error. Use the return value to know when
/// to check for an error object. A return value of NO will always produce an error object.
///
/// @returns YES if the condition was satisfied, otherwise NO.
- (BOOL)evaluateForOperation:(VDSOperation* _Nonnull)operation
                       error:(NSError* __autoreleasing _Nullable * _Nullable)error;

@end


#pragma mark - VDSOperation -

@protocol VDSOperation <NSObject>

/// @summary Notifies the operation that a queue will be added it to its set of operations.
/// @param queue The queue the operation will be added to.
- (void)willEnqueue:(VDSOperationQueue * _Nonnull)queue;

@end

#pragma mark - VDSOperation -


/// @summary The VDSOperation class extends NSOperation and adds functionality that enables
/// conditional execution, delegate and observer notifications, and an extended state
/// system that enables more granular readiness behavior.
@interface VDSOperation : NSOperation <VDSOperation>


/// @summary Identifies the current extended state used by VDSOperation.
///
/// @discussion Possible values include (in order):
///
/// VDSOperationInitialized - The initial state of the operation.
///
/// VDSOperationPending - The operation can now begin evaluating conditions.
///
/// VDSOperationEvaluating - The operation is evaluating its conditions.
///
/// VDSOperationReady - All conditions have been satisfied and the operation can now execute.
///
/// VDSOperationExecuting - The opertion is executing its task.
///
/// VDSOperationFinishing - The operation has completed its task but has not notified its queue yet.
///
/// VDSOperationFinished  - The operation is done executing and has notified all interested parties.
///
/// @note This property is Key-Value Observable.
@property(readonly) VDSOperationState state;

/// @summary The lock used to guarantee that only one thread may change the state
/// value at a time.
@property(strong, readonly, nonnull, nonatomic) NSLock* stateCoordinator;

/// The conditions the operation must satisfy before it can execute.
@property(strong, readonly, nonnull, nonatomic) NSArray<VDSOperationCondition*>* conditions;

/// @summary The observers that have registed for a subset of delegate notifications.
///
/// @discussion Typically observers are constrained to other operations that need to monitor
/// the state and/or result of the current operation, for example as a means
/// of aggregating results prior to their own execution.
///
/// In addition, anonymous observers can be added using a VDSBlockObserver instance. These objects
/// enable you to add functionality to the operation without having to subclass
/// it. Block observers are the right option when the additional functionality
/// is limited and subclassing would result in an object that would only be used
/// once, which for operations is a very common scenario.
///
/// @note Other options for observation include
/// subscribing to notifications or direct Key-Value Observing of the operation. Use
/// these options when more widespread or more granular notifications, respectively,
/// are required.
@property(strong, readonly, nonnull, nonatomic) NSArray<id<VDSOperationObserver>>* observers;

/// @summary Upon completion, contains the errors, if any, reported during execution of the
/// operation. During execution, the array is updated as errors occur. This property
/// is Key-Value Observable.
@property(strong, readonly, nonnull) NSArray<NSError*>* errors;


/// @summary An object conforming to the VDSOperationDelegate protocol. The operation
/// delegate has the opportunity to both monitor and prevent the operation
/// from taking certain actions before and during execution.
@property(weak, readwrite, nullable) id<VDSOperationDelegate> delegate;

#pragma mark  Object Lifecycle




#pragma mark  Configuration Behaviors

/// @summary Adds a VDSOperationCondition to the operation.
///
/// @param condition The condition that should be added to the Operation.
/// @param error An error object describing the error. Use the return value to know when
/// to check for an error object. A return value of NO will always produce an error object.
///
/// @returns YES if the condition was successfully added, otherwise NO.
- (BOOL)addCondition:(VDSOperationCondition* _Nonnull)condition
               error:(NSError* __autoreleasing _Nullable * _Nullable)error;

/// @summary Removes a VDSOperationCondition from the operation.
///
/// @param condition The condition to be removed. Uses isEquals: and removes the
/// first matching condition.
/// @param error An error object describing the error. Use the return value to know when
/// to check for an error object. A return value of NO will always produce an error object.
///
/// @returns YES if the condition was successfully removed, otherwise NO.
- (BOOL)removeCondition:(VDSOperationCondition* _Nonnull)condition
                  error:(NSError* __autoreleasing _Nullable * _Nullable)error;

/// @summary Adds an observer, typically another operation, to the receiver.
///
/// @param observer An object conforming to the VDSOperationObserver protocol.
/// @param error An error object describing the error. Use the return value to know when
/// to check for an error object. A return value of NO will always produce an error object.
///
/// @returns YES if the observer was successfully added, otherwise NO.
- (BOOL)addObserver:(id<VDSOperationObserver> _Nonnull)observer
              error:(NSError* __autoreleasing _Nullable * _Nullable)error;

/// @summary Removes a VDSOperationObserver from the operation.
///
/// @param observer An object conforming to the VDSOperationObserver protocol. Use isEquals
/// and removes the first matching observer.
/// @param error An error object describing the error. Use the return value to know when
/// to check for an error object. A return value of NO will always produce an error object.
///
/// @returns YES if the observer was successfully removed, otherwise NO.
- (BOOL)removeObserver:(id _Nonnull)observer
                 error:(NSError* __autoreleasing _Nullable * _Nullable)error;

/// @summary Adds a completion block to the operation. If a completion block exists, the
/// existing block is wrapped in a block that will execute the existing block first
/// followed by the new completion block.
///
/// @param completionBlock A completion block that will be executed after the operation
/// enters its finished state.
- (void)addCompletionBlock:(void(^_Nonnull)(void))completionBlock;

/// Adds a dependency while reporting an error if the dependency can not be added.
/// This method is preferred over addDependency: for adding dependencies to
/// VDSOperation and its subclasses.
///
/// @param operation The operation to add as a dependency
/// @param error An error object describing the error. Use the return value to know when
/// to check for an error object. A return value of NO will always produce an error object.
///
/// @returns YES if the dependency was successfully added, otherwise NO.
- (BOOL)addDependency:(NSOperation* _Nonnull)operation
                error:(NSError* __autoreleasing _Nullable * _Nullable)error;

/// @summary A convenience method that adds each of the dependencies to the operation by repeatedly
/// calling the addDependency: method for each of the elements in the array.
///
/// @param dependencies An array of dependencies that will be added to the receiver.
/// @param error An error object describing the error. Use the return value to know when
/// to check for an error object. A return value of NO will always produce an error object.
///
/// @returns YES if the dependencies were successfully added, otherwise NO.
- (BOOL)addDependencies:(NSArray<NSOperation*>* _Nonnull)dependencies
                  error:(NSError* __autoreleasing _Nullable * _Nullable)error;


#pragma mark - Execution Behaviors


/// @summary Call this method to determine whether an operation can transition to
/// a new VDSOperationState.
///
/// @param state A VDSOperationState the operation could transition to.
/// @param error An error object describing the error. Use the return value to know when
/// to check for an error object. A return value of NO will always produce an error object.
///
/// @returns YES if the can transition to state, otherwise NO.
- (BOOL)canTransitionToState:(VDSOperationState)state
                       error:(NSError* __autoreleasing _Nullable * _Nullable)error;

/// @summary Evaluates the conditions associated with the operation, returning YES if conditions
/// have been satisfied, and NO if they have not been satisfied.
///
/// @param error An error object describing the error. Use the return value to know when
/// to check for an error object. A return value of NO will always produce an error object.
///
/// @returns YES if the conditions have been satisfied, otherwise NO.
- (BOOL)evaluateConditions:(NSError* __autoreleasing _Nullable * _Nullable)error;


/// @summary Produces an operation of the specified class type, typically for use as a dependency
/// by the receiver.
///
/// @param operation The coperation produced by the receiver.
- (void)produceOperation:(NSOperation* _Nonnull)operation;

/// @summary Primary override point for subclasses to specialize a VDSOperation.
- (void)execute;


/// Convenience method that can be called when an operation finishes with or without an error. Calls
/// finishWithErrors:. This method is useful as it corresponds to a standard completion patterns used in
/// Cocoa.
/// 
/// @param error An error object describing the error if one occurred.
- (void)finish:(NSError* _Nullable)error;

/// @summary Called to finsish the execution of the operation's task and to notifiy the operation
/// and any interested parties that the main task of the operation has completed and the
/// operation is now in a finishing state.
///
/// @discussion This method calls finishing, the subclass
/// override point. At the beginning of this method, the operation state is VDSOperationFinishing.
/// At its conclusion, the operation state is VDSOperationFinished.
///
/// @param errors An array containing error objects to be added to the operationErrors array.
- (void)finishWithErrors:(NSArray<NSError*>* _Nullable)errors;


/// @summary Override point for subclasses to add additional behavior during the finishing process.
///
/// @discussion This method is called by finishWithErrors: after all errors have been set on the object
/// and the operation state has changed to VDSOperationFinishing.
- (void)finishing;


/// @summary Cancels the operation and adds the error to the operationErrors array.
///
/// @param error An error object describing the error.
- (void)cancelWithError:(NSError* _Nullable)error;


@end

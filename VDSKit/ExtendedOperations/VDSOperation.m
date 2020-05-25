//
//  VDSOperation.m
//  VDSKit
//
//  Created by Erikheath Thomas on 5/6/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import "VDSOperation.h"
#import "VDSOperationCondition.h"
#import "VDSOperationObserver.h"
#import "VDSOperationDelegate.h"





#pragma mark - NSOperation+VDSOperation -

@implementation NSOperation (VDSOperation)

/// If NS_BLOCK_ASSERTIONS is defined, then this method is
/// effectively a no-op when completion block is nil.
///
- (void)addCompletionBlock:(void (^)(void))completionBlock
{
    // It is a programmer error to pass a nil completionBlock.
    NSAssert(completionBlock != nil, VDS_NIL_ARGUMENT_MESSAGE(nil, _cmd));

    if (self.completionBlock != nil) {
        void(^existingBlock)(void) = self.completionBlock;
        self.completionBlock = ^{
            existingBlock();
            completionBlock();
        };
    } else {
        self.completionBlock = completionBlock;
    }
}

@end





#pragma mark - VDSOperation Extension -

@interface VDSOperation ()

/// These redeclarations are to enable 'private' read/write capability. There
/// should be no need to alter this behavior in subclasses (i.e. make read/write
/// public).
///
@property(readwrite) BOOL enqueued;
@property(strong, readwrite, nonnull) NSArray<VDSOperationCondition*>* conditions;
@property(strong, readwrite, nonnull) NSArray<id<VDSOperationObserver>>* observers;
@property(strong, readwrite, nonnull) NSArray<NSError*>* errors;

@end





#pragma mark - VDSOperation -

@implementation VDSOperation



#pragma mark Object Lifecycle

- (instancetype _Nullable)init
{
    self = [super init];
    if (self != nil) {
        _errors = [NSArray new];
        _observers = [NSArray new];
        _conditions = [NSArray new];
        _enqueued = NO;
    }
    return self;
}



#pragma mark Configuration

- (void)addCondition:(VDSOperationCondition* _Nonnull)condition
{
    
    /// It is a programmer error to pass a nil condition. If NS_BLOCK_ASSERTIONS
    /// is defined, the conditions array proxy will throw an exception when
    /// adding a nil object is attempted.
    ///
    NSAssert(condition != nil, VDS_NIL_ARGUMENT_MESSAGE(nil, _cmd));
     
    /// The condition must be a VDSOperationCondition or subclass. The
    /// reason for this is that the VDSOperationQueue requires a specific
    /// set of methods and properties to be available on a operation for
    /// condition processing. A standard NSOperation does not have these,
    /// and adding the infrastructure for this to an operation gives a
    /// false sense that you can use a regular NSOperationQueue and get
    /// condition-based behavior.
    ///
    NSAssert([condition isKindOfClass:[VDSOperationCondition class]], VDS_UNEXPECTED_ARGUMENT_TYPE_MESSAGE(condition, @"condition", _cmd, NSStringFromClass([VDSOperationCondition class])));

    /// The operation must not be enqueued to add a condition.
    /// If it is, there is likely a race condition or other programmer error.
    /// The reason for this requirement is that when the operation is being
    /// enqueued, the VDSOperationQueue is coordinating the processing of the
    /// conditions. Once that processing has begun, a new condition is unlikely
    /// to make it in to the set processed by the queue.
    ///
    NSAssert(!self.enqueued, VDS_OPERATION_COULD_NOT_ADD_CONDITION_MESSAGE(self.name, condition));
    
    [[self mutableArrayValueForKey:NSStringFromSelector(@selector(conditions))] addObject:condition];
    
}


- (void)addObserver:(id<VDSOperationObserver> _Nonnull)observer
{
    
    /// It is a programmer error to pass a nil observer. If NS_BLOCK_ASSERTIONS
    /// is defined, the observers array proxy will throw an exception when
    /// adding a nil object is attempted.
    ///
    NSAssert(observer != nil, VDS_NIL_ARGUMENT_MESSAGE(nil, _cmd));
     
    /// The observer must conform to VDSOperationObserver. The
    /// reason for this is that the VDSOperationQueue requires a specific
    /// set of methods and properties to be available on a operation for
    /// observer processing. A standard NSOperation does not have these,
    /// and adding the infrastructure for this to an operation gives a
    /// false sense that you can use a regular NSOperationQueue and get
    /// observer-based behavior. Also, this processing
    /// is only done once in the lifetime of the operation.
    ///
    NSAssert([observer conformsToProtocol:@protocol(VDSOperationObserver)], VDS_UNEXPECTED_ARGUMENT_TYPE_MESSAGE(observer, @"observer", _cmd, NSStringFromProtocol(@protocol(VDSOperationObserver))));
    
    /// The operation must not be enqueued to add an observer.
    /// If it is, there is likely a race condition or other programmer error.
    /// The reason for this requirement is that when the operation is being
    /// enqueued, the VDSOperationQueue is coordinating the processing of the
    /// observers. Once that processing has begun, a new observer is unlikely
    /// to make it in to the set processed by the queue. Also, this processing
    /// is only done once in the lifetime of the operation.
    ///
    NSAssert(!self.enqueued, VDS_OPERATION_COULD_NOT_ADD_OBSERVER_MESSAGE(self.name, observer));

    [[self mutableArrayValueForKey:NSStringFromSelector(@selector(observers))] addObject:observer];

}


- (void)willEnqueue
{
    if (_enqueued == NO) { self.enqueued = YES; }
}



#pragma mark Execution

/// @summary Evaluates the conditions associated with the operation.
///
/// @discussion If the conditions are not satisfied, this method adds any
/// errors it recieves from the conditions processing to the operation's errors
/// array. This method is called at the beginning of the start routine.
/// 
- (void)evaluateConditions
{
    NSError* conditionError = nil;
    if ([VDSOperationCondition evaluateConditionsForOperation:self error:&conditionError] == NO) {
        [[self mutableArrayValueForKey:NSStringFromSelector(@selector(errors))] addObject:conditionError];
    }
}


/// Start is overridden, but calls the super class version to do the normal setup
/// for an operation that is designed to be run on a queue. This means that a VDSOperation
/// doesn't fall into the asynchronous operation design pattern where start is overriden and state
/// changes must be triggered manually. Instead, VDSOperation extends the functionality of the
/// start method, taking care to ensure that the -(void)finishWithErrors: method is called even if the operation
/// has been canceled before the start method is called.
///
- (void)start {
    [self evaluateConditions];
    [super start];
    if (self.isCancelled == YES) {
        /// If the opertaion is canceled, main will not be called,
        /// so finish must be called from here.
        [self finishWithErrors:nil];
    }
}


/// In VDSOperation, main is part of the infrastructure of the class, and the execute method is
/// provided to subclassers in its place. The -(void)main method is responsible for checking for
/// errors which, by default cause the operation to not execute, as well as responding to a
/// cancel state which will also cause the method to not execute. In the event that the method
/// does not call the execute method, it will call the -(void)finishWithErrors: method.
///
- (void)main
{
    if (self.errors.count == 0 && self.isCancelled == NO) {
        for (id<VDSOperationObserver>observer in self.observers) {
            if ([observer respondsToSelector:@selector(operationDidStart:)]) {
                [observer operationDidStart:self];
            }
        }
        [self execute];
    } else {
        [self finishWithErrors:nil];
    }
}


/// Execute is the main override point for subclasses. Subclasses should override this method
/// and either call -(void)finishWithErrors: directly at the appropriate point,
/// or if the task is completed within the execute method, call super at the end of the implementation.
///
- (void)execute {
    [self finishWithErrors:nil];
}



/// This is a convenience method that can be used in execute or some other method that is
/// part of the operation's task to indicate that an operation should
/// move into a finishing state. This method calls -(void)finishWithErrors:, but can be
/// overridden to perform other interstitial steps (before finishing begins but after a task
/// is completed).
///
- (void)finish:(NSError *_Nullable)error
{
    NSArray* errorArray = nil;
    if (error != nil) {
        errorArray = @[error];
    }
    [self finishWithErrors:errorArray];
}


/// This is the main infrastructure of the class for finishing up an operation.
/// It adds any errors it receives to the operations errors array, calls the subclass's
/// finishing customizations, then performs delegate and observer notifications. This
/// method is not designed to be overridden. Instead, perform customizations using the
/// -(void)finishing method.
///
- (void)finishWithErrors:(NSArray<NSError *> *)errors
{
    [[self mutableArrayValueForKey:NSStringFromSelector(@selector(errors))] addObjectsFromArray:errors];
    
    [self finishing];
    
    if ([_delegate respondsToSelector:@selector(operationDidFinish:)]) {
        [_delegate operationDidFinish:self];
    }
    
    for (id<VDSOperationObserver> observer in _observers) {
        [observer operationDidFinish:self];
    }
}


/// Customization point for finishing an operation. This method is called after the operation
/// has completed its task but before delegates or observers are notified of the finishing
/// state. Note that finish with errors and finishing may complete before or after an operation
/// is marked as finished due to the effects of cancelation.
///
- (void)finishing
{
    return;
}


/// Allows a cancelation to be performed on an operation with an optional error added
/// to the operation's errors array to describe the reason for the cancellation.
///
- (void)cancelWithError:(NSError* _Nullable)error
{
    if (error != nil) {
        [[self mutableArrayValueForKey:NSStringFromSelector(@selector(errors))] addObject:error];
    }
    [self cancel];
}


@end

//
//  VDSGroupOperation.m
//  VDSKit
//
//  Created by Erikheath Thomas on 4/30/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import "VDSGroupOperation.h"





#pragma mark - VDSGroupOperation Extension -

@interface VDSGroupOperation ()

#pragma mark - Properties

/// The start operation is used to coordinate the execution of all
/// other operations added to the queue. No operation can execute
/// until the start operation has begun.
@property(strong, readonly, nonnull) NSOperation* startOperation;


/// The finish operation is used to signal that the operation is
/// performing its finishing work and no other operations may be
/// added to the internal queue.
@property(strong, readonly, nonnull) NSOperation* finishOperation;


@end





#pragma mark - VDSGroupOperation -

@implementation VDSGroupOperation

#pragma mark - Object Lifecycle

+ (instancetype _Nullable)initWithOperations:(NSOperation* _Nullable)operation, ...
{
    NSMutableArray* arguments = [NSMutableArray new];
    id object = nil;
    va_list argumentList;
    if (operation != nil) {
        [arguments addObject:operation];
        va_start(argumentList, operation);
        while ((object = va_arg(argumentList, id))) {
            [arguments addObject:object];
        }
        va_end(argumentList);
    }
    return [[VDSGroupOperation alloc] initWithOperations:arguments];
}


/// This is the designated initializer for VDSGroupOperation.
///
- (instancetype _Nullable)initWithOperations:(NSArray<NSOperation*>* _Nullable)operations
{
    self = [super init];
    if (self != nil) {
        _startOperation = [NSBlockOperation blockOperationWithBlock:^{ }];
        _finishOperation = [NSBlockOperation blockOperationWithBlock:^{ }];
        _internalQueue = [VDSOperationQueue new];
        [_internalQueue setSuspended:YES];
        _internalQueue.delegate = self;
        [_internalQueue addOperation:_startOperation];
        for (NSOperation* operation in operations) {
            [self addOperation:operation];
        }
    }
    return self;
}


/// Overridden to call the designated initializer.
///
- (instancetype _Nullable)init {
    return [self initWithOperations:nil];
}


#pragma mark - Configuration Behavior

/// This is the primary point for adding an operation. Subclasses
/// should use this method to add additional behavior when adding
/// an operation.
///
- (void)addOperation:(NSOperation* _Nonnull)operation
{
    
    /// It is a programmer error to pass a nil operation.
    NSAssert(operation != nil, VDS_NIL_ARGUMENT_MESSAGE(nil, _cmd));
    
    /// The operation must be a NSOperation or subclass.
    NSAssert([operation isKindOfClass:[NSOperation class]], VDS_UNEXPECTED_ARGUMENT_TYPE_MESSAGE(operation, @"operation", _cmd, NSStringFromClass([NSOperation class])));
    
    [_internalQueue addOperation:operation];
}


/// Convenience method for adding operations to the internal queue.
///
- (void)addOperations:(NSArray<NSOperation*>* _Nonnull)operations
{
    /// It is a programmer error to pass a nil operation.
    NSAssert(operations != nil, VDS_NIL_ARGUMENT_MESSAGE(nil, _cmd));
    
    /// The operation must be a NSOperation or subclass.
    NSAssert([operations isKindOfClass:[NSArray class]], VDS_UNEXPECTED_ARGUMENT_TYPE_MESSAGE(operations, @"operations", _cmd, NSStringFromClass([NSArray class])));

    for (NSOperation* operation in operations) {
        [self addOperation:operation];
    }
}



#pragma mark - Execution Behaviors

/// Used to cancel both the operation and its internal queue.
///
- (void)cancel
{
    [_internalQueue cancelAllOperations];
    [super cancel];
}


/// Subclasses must call this method or reimplement its functionality
/// as the queue will not execute if it is suspended nor will the
/// operation know it is done if the finish operation is not added
/// to the internal queue.
///
- (void)execute
{
    [_internalQueue setSuspended:NO];
    [_internalQueue addOperation:_finishOperation];
}


/// Used by subclasses to add behavior when an operation in the internal
/// queue has completed its task.
- (void)operationDidFinish:(NSOperation *)operation {
    return;
}


 
#pragma mark - Queue Delegate Behaviors

/// The group operation is the delegate of its internal queue
/// and uses this delegate method to signal to interested parties
/// that an operation on its internal queue has finished its task.
///
- (void)operationQueue:(VDSOperationQueue * _Nonnull)queue
    operationDidFinish:(NSOperation * _Nonnull)operation {
    if ([operation isKindOfClass:[VDSOperation class]] == YES) {
        [[self mutableArrayValueForKey:NSStringFromSelector(@selector(errors))] addObjectsFromArray:((VDSOperation*)operation).errors];
    }
    if (operation == _finishOperation) {
        [_internalQueue setSuspended:YES];
        [self finish:nil];
    } else if (operation != _startOperation) {
        [self operationDidFinish:operation];
    }
    return;
}


/// The group operation is the delegate of its internal queue
/// and uses this delegate method to determine if the finish
/// operation is executing or has completed. In either of these
/// cases, additional operations can not be added to the group's
/// internal queue.
///
- (BOOL)operationQueue:(VDSOperationQueue * _Nonnull)queue
    shouldAddOperation:(NSOperation * _Nonnull)operation {
    
    // Once the finish operation begins, no additional operations
    // can be added.
    return !_finishOperation.isFinished && !_finishOperation.isExecuting;
    
}


/// The group operation is the delegate of its internal queue
/// and uses this delegate method to configure operations as
/// they are added to the internal queue.
///
- (NSOperation* _Nonnull)operationQueue:(VDSOperationQueue * _Nonnull)queue
      willAddOperation:(NSOperation* _Nonnull)operation {
    
    /// All operations should be added as a dependency of the
    /// finish operation so that the Group Operation has an
    /// end point.
    if (operation != _finishOperation) {
        [_finishOperation addDependency:operation];
    }
    
    /// All operations depend on the start operation to execute before
    /// they can execute (or even evaluate conditions)
    if (operation != _startOperation) {
        [operation addDependency:_startOperation];
    }

    return operation;
}


@end

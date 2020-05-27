//
//  VDSOperationQueue.m
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


#import "VDSOperationQueue.h"
#import "VDSBlockObserver.h"
#import "../VDSErrorConstants.h"
#import "VDSOperationCondition.h"
#import "VDSOperationDelegate.h"
#import "VDSOperationMutexCoordinator.h"





#pragma mark - VDSOperationQueue -

@implementation VDSOperationQueue


/// The -(void)addOperation: override provides some important checking
/// and error reporting via assertions. But more importantly, it
/// sets up opreations to correctly interact with the operation
/// queue, with the mutex coordinator, and with observers (of which
/// the queue is one).
///
- (void)addOperation:(NSOperation*)operation
{
    /// It is a programmer error to pass a nil operation. While
    /// this method is annotated as _Nonnull, when used by
    /// Objective-C, it's always possible to unknowingly bypass these compiler
    /// based requirements. For swift based development, it may
    /// make sense to turn off assertions as the annotations
    /// should require any calls to this method to be a non-optional
    /// type (i.e. nil checked).
    ///
    NSAssert(operation != nil, VDS_NIL_ARGUMENT_MESSAGE(nil, _cmd));
    
    /// The operation must be a NSOperation or subclass.
    NSAssert([operation isKindOfClass:[NSOperation class]], VDS_UNEXPECTED_ARGUMENT_TYPE_MESSAGE(operation, @"operation", _cmd, NSStringFromClass([NSOperation class])));
        
    /// The delegate can abort adding the operation to the queue. This functionality
    /// provides an important mechanism for controlling how the queue operates
    /// without having to resort to canceling operations.
    ///
    /// Besides coalescing operations (similar to coalescing repeated NSNotifications),
    /// useful filtering could include removing operations due to system conditions
    /// (low memory, no wifi, spotty cellular, etc.) or removing opertions to
    /// increase performance (e.g. blocking a compacting utility operation
    /// that will be added again at a later date).
    ///
    /// While it's possible for some of these decisions to be made using conditions,
    /// an operation may not exist when a decision on execution needs to be made.
    /// For example, an operation may not be instantiated when a low memory
    /// notification is dispatched.
    ///
    if (self.delegate != nil &&
        [self.delegate respondsToSelector:@selector(operationQueue:shouldAddOperation:)] == YES &&
        [self.delegate operationQueue:self shouldAddOperation:operation] == NO) {
        return;
    }
    
    // Notify delegate an operation will be added to the queue.
    id opx = operation;
    if (self.delegate && [self.delegate respondsToSelector:@selector(operationQueue:willAddOperation:)]) {
        opx = [self.delegate operationQueue:self
                     willAddOperation:operation];
    }


    /// This lets NSOperation and other subclasses be interleaved with
    /// VDSOperation and its subclasses.
    ///
    if ([opx isKindOfClass:[VDSOperation class]] == NO) {
        
        /// To enable notification when the operation finishes,
        /// a completion block is added or appended to with a delegate
        /// call.
        VDSOperationQueue* __weak queue = self;
        NSOperation* __weak op = opx;
        [opx addCompletionBlock:^{
            if (queue != nil &&
                [queue respondsToSelector:@selector(operationDidFinish:)]) {
                [queue operationDidFinish:op];
            }
        }];
                
    } else {
        /// This section is exclusively for VDSOperation and its subclasses.
        VDSOperation* vdsOperation = (VDSOperation*)opx;
        
        /// Notify the vdsOperation that it will be enqued. This should prevent additional
        /// conditions or dependencies from being added to it.
        [vdsOperation willEnqueue];
        
        VDSBlockObserver* observer = nil;
        NSMutableArray* mutexConditions = [NSMutableArray new];
        
        /// If any of the conditions require mutual exclusivity, add them to the shared Mutex
        /// coordinator. Also, the operation must be removed from the mutex coordinator once
        /// the operation finishes.
        for (VDSOperationCondition* condition in vdsOperation.conditions) {
            if ([[condition class] isMutuallyExclusive] == YES) {
                [mutexConditions addObject:NSStringFromClass([condition class])];
            }
        }
        
        if (mutexConditions.count > 0) {
            observer = [[VDSBlockObserver alloc] initWithStartOperationHandler:nil
                                                        finishOperationHandler:^(VDSOperation * _Nonnull finishOperation) {
                [VDSOperationMutexCoordinator.sharedCoordinator removeOperation:vdsOperation
                                                              forConditionTypes:mutexConditions];
            }];
            [vdsOperation addObserver:observer];
            [VDSOperationMutexCoordinator.sharedCoordinator addOperation:vdsOperation
                                                          forConditionsTypes:mutexConditions];
        }

        
        /// The queue is always the delegate of the VDSOperation.
        vdsOperation.delegate = self;
        
        /// Add depencies to the current operation so that conditions may be satisfied.
        for (VDSOperationCondition* condition in vdsOperation.conditions) {
            NSOperation* dependency = [condition dependencyForOperation:vdsOperation];
            if (dependency != nil) {
                [operation addDependency:dependency];
                [self addOperation:dependency];
            }
        }
        
        
    }
        

    [super addOperation:opx];
    
}


/// Added as a convenient way to add multiple operations. This
/// is very useful for group operations.
///
- (void)addOperations:(NSArray<NSOperation*> *)operations
{
    /// It is a programmer error to pass a nil argument.
    NSAssert(operations != nil, VDS_NIL_ARGUMENT_MESSAGE(nil, _cmd));
    
    for (NSOperation* operation in operations) {
        [self addOperation:operation];
    }
}



#pragma mark VDSOperationDelegate

- (void)operationDidFinish:(VDSOperation * _Nonnull)operation {
    if ([self.delegate respondsToSelector:@selector(operationQueue:operationDidFinish:)]) {
        [self.delegate operationQueue:self
                   operationDidFinish:operation];
    }
}


- (void)operationDidStart:(VDSOperation * _Nonnull)operation { 
    if ([self.delegate respondsToSelector:@selector(operationQueue:operationDidStart:)]) {
        [self.delegate operationQueue:self
                    operationDidStart:operation];
    }
    
}


- (void)operationWillFinish:(VDSOperation * _Nonnull)operation { 
    if ([self.delegate respondsToSelector:@selector(operationQueue:operationWillFinish:)]) {
        [self.delegate operationQueue:self
                  operationWillFinish:operation];
    }
    
}


- (void)operationWillStart:(VDSOperation * _Nonnull)operation { 
    if ([self.delegate respondsToSelector:@selector(operationQueue:operationWillStart:)]) {
        [self.delegate operationQueue:self
                   operationWillStart:operation];
    }
    
}


@end

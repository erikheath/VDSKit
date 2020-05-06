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

- (void)addOperation:(NSOperation*)operation
{
    // It is a programmer error to pass a nil operation.
    NSAssert(operation != nil, VDS_NIL_ARGUMENT_MESSAGE(nil, _cmd));
    
    // The operation must be a NSOperation or subclass.
    NSAssert([operation isKindOfClass:[NSOperation class]], VDS_UNEXPECTED_ARGUMENT_TYPE_MESSAGE(operation, @"operation", _cmd, NSStringFromClass([NSOperation class])));
        
    // The delegate can abort adding the operation to the queue.
    if (self.delegate != nil &&
        [self.delegate respondsToSelector:@selector(operationQueue:shouldAddOperation:)] == YES &&
        [self.delegate operationQueue:self shouldAddOperation:operation] == NO) {
        return;
    }

    // Let NSOperation and other subclasses be interleaved with
    // VDSOperation and its subclasses. The queue is always the
    // delegate of operations.
    if ([operation isKindOfClass:[VDSOperation class]] == NO) {
        
        // To enable notification when the operation finishes,
        // a completion block is added or appended to with a delegate
        // notification.
        VDSOperationQueue* __weak queue = self;
        NSOperation* __weak op = operation;
        [operation addCompletionBlock:^{
            if (queue != nil &&
                [queue respondsToSelector:@selector(operationDidFinish:)]) {
                [queue operationDidFinish:op];
            }
        }];
                
    } else {
        // This is exclusively for VDSOperation and its subclasses.
        VDSOperation* vdsOperation = (VDSOperation*)operation;
        
        VDSBlockObserver* observer = nil;
        NSMutableArray* mutexConditions = [NSMutableArray new];
        
        // If any of the conditions require mutual exclusivity, add them to the shared Mutex
        // coordinator. Also, the operation must be removed from the mutex coordinator once
        // the operation finishes.
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

        
        // The queue is always the delegate of the operation.
        vdsOperation.delegate = self;
        
        //Add depencies to the current operation so that conditions may be satisfied.
        for (VDSOperationCondition* condition in vdsOperation.conditions) {
            NSOperation* dependency = [condition dependencyForOperation:vdsOperation];
            if (dependency != nil) {
                [operation addDependency:dependency];
                [self addOperation:dependency];
            }
        }
        
        [vdsOperation willEnqueue];
    }
        
    // Finally, notify delegates and add the operation to the queue.
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(operationQueue:willAddOperation:)]) {
        [self.delegate operationQueue:self
                     willAddOperation:operation];
    }

    [super addOperation:operation];
    
}

- (void)addOperations:(NSArray<NSOperation*> *)operations
{
    // It is a programmer error to pass a nil condition.
    NSAssert(operations != nil, VDS_NIL_ARGUMENT_MESSAGE(nil, _cmd));
    
    for (NSOperation* operation in operations) {
        [self addOperation:operation];
    }
}


#pragma mark VDSOperationDelegate

- (void)operation:(VDSOperation * _Nonnull)operation
didProduceOperation:(VDSOperation * _Nonnull)newOperation {
    
}

- (BOOL)operation:(VDSOperation * _Nonnull)operation
shouldProduceOperation:(Class _Nonnull)newOperation {
    return YES;
}

- (void)operationDidFinish:(VDSOperation * _Nonnull)operation { 
    [self.delegate operationQueue:self
               operationDidFinish:operation];
}

- (void)operationDidStart:(VDSOperation * _Nonnull)operation { 
    
}

- (BOOL)operationShouldStart:(VDSOperation * _Nonnull)operation { 
    return YES;
}

- (void)operationWillFinish:(VDSOperation * _Nonnull)operation { 
    
}

- (void)operationWillStart:(VDSOperation * _Nonnull)operation { 
    
}

- (Class _Nullable)opertion:(VDSOperation * _Nonnull)operation
       willProduceOperation:(Class _Nonnull)newOperation {
    return nil;
}

@end

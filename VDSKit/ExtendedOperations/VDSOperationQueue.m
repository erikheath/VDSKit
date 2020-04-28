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


#pragma mark - VDSOperationMutexCoordinator -

@interface VDSOperationMutexCoordinator ()

@property(strong, readonly, nonnull) dispatch_queue_t serializer;

@property(strong, readonly, nonnull) NSMutableDictionary* mutexOperations;

@end

@implementation VDSOperationMutexCoordinator

static VDSOperationMutexCoordinator* _sharedCoordinator;

// This ensures that this will only be used once whether its used by
// shared coordinator first or init first.
static dispatch_once_t onceToken;

@synthesize serializer = _serializer;
@synthesize mutexOperations = _mutexOperations;

+ (VDSOperationMutexCoordinator*)sharedCoordinator
{
    dispatch_once(&onceToken, ^{
        _sharedCoordinator = [[VDSOperationMutexCoordinator alloc] init];
    });
    return _sharedCoordinator;
}

- (instancetype)init {
    id __block internalSelf = self;
    dispatch_once(&onceToken, ^{
        internalSelf = [super init];
        if (internalSelf != nil) {
            _serializer = dispatch_queue_create("VDSOperationMutexCoordinator", DISPATCH_QUEUE_SERIAL);
            _mutexOperations = [NSMutableDictionary new];
            _sharedCoordinator = internalSelf;
        }
    });
    return _sharedCoordinator;
}

- (void)addOperation:(VDSOperation *)operation
  forConditionsTypes:(NSArray<NSString*> *)conditionTypes {
    dispatch_sync(_serializer, ^{
        for (NSString* conditionType in conditionTypes) {
            NSMutableArray* operationsForConditionType = self->_mutexOperations[conditionType];
            if (operationsForConditionType == nil) {
                operationsForConditionType = [NSMutableArray new];
                [_mutexOperations setObject:operationsForConditionType
                                     forKey:conditionType];
            }
            VDSOperation* lastOperation = operationsForConditionType.lastObject;
            if (lastOperation != nil) { [operation addDependency:lastOperation]; }
            [operationsForConditionType addObject:operation];
        }
    });
}

- (void)removeOperation:(VDSOperation *)operation
      forConditionTypes:(NSArray<Class> *)conditionTypes {
    dispatch_async(_serializer, ^{
        for (NSString* conditionType in conditionTypes) {
            NSMutableArray* operationsForConditionType = self->_mutexOperations[conditionType];
            [operationsForConditionType removeObject:operation];
        }
    });
}

@end


#pragma mark - VDSOperationQueue -

@implementation VDSOperationQueue

// The basic addOperation is overridden to encourage the use of
// addOperation:error: and to indicate that the queue should
// be used with VDSOperations only. 
- (void)addOperation:(NSOperation *)op {
    return;
}

- (BOOL)addOperation:(VDSOperation*)operation
               error:(NSError *__autoreleasing  _Nullable * _Nullable)error
{
    BOOL success = YES;
    VDSBlockObserver* observer = nil;
    NSMutableArray* mutexConditions = [NSMutableArray new];
    
    if (self.delegate != nil &&
        [self.delegate respondsToSelector:@selector(operationQueue:shouldAddOperation:)] == YES) {
        success = [self.delegate operationQueue:self
                             shouldAddOperation:operation];
        if (success == NO && error != NULL) {
            *error = [NSError errorWithDomain:VDSKitErrorDomain
                                         code:VDSOperationEnqueFailed
                                     userInfo:@{NSDebugDescriptionErrorKey: VDS_QUEUE_DELEGATE_BLOCKED_ENQUEMENT_MESSAGE(operation.name, self.name)}];
        }
    }

    // If any of the conditions require mutual exclusivity, add them to the shared Mutex
    // coordinator. Also, the operation must be removed from the mutex coordinator once
    // the operation finishes.
    for (VDSOperationCondition* condition in operation.conditions) {
        if ([[condition class] isMutuallyExclusive] == YES) {
            [mutexConditions addObject:NSStringFromClass([condition class])];
        }
    }

    if (success == YES && mutexConditions.count > 0) {
        observer = [[VDSBlockObserver alloc] initWithStartOperationHandler:nil
                                                   produceOperationHandler:nil
                                                    finishOperationHandler:^(VDSOperation * _Nonnull finishOperation) {
            [VDSOperationMutexCoordinator.sharedCoordinator removeOperation:operation
                                                          forConditionTypes:mutexConditions];
        }];
    }
    
    if (success == YES && (success = [operation addObserver:observer error:error]) == YES) {
        [VDSOperationMutexCoordinator.sharedCoordinator addOperation:operation
                                                  forConditionsTypes:mutexConditions];
    }
    
    // Wait to add dependencies until error generating methods have returned without errors.
    if (success == YES) {
        // The queue is always the delegate of the operation.
        operation.delegate = self;
        
        //Add depencies to the current operation so that conditions may be satisfied.
        for (VDSOperationCondition* condition in operation.conditions) {
            NSOperation* dependency = [condition dependencyForOperation:operation];
            if (dependency != nil) {
                [operation addDependency:dependency];
                [self addOperation:dependency];
            }
        }
    }
    
    // Finally, message the operation that it is being enqueued and add the operation to
    // the queue now that its execution graph is set up.
    if (success) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(operationQueue:willAddOperation:)]) {
            [self.delegate operationQueue:self
                         willAddOperation:operation];
        }
        [operation willEnqueue:self];
        [super addOperation:operation];
        if (self.delegate && [self.delegate respondsToSelector:@selector(operationQueue:didAddOperation:)]) {
            [self.delegate operationQueue:self
                         didAddOperation:operation];
        }
    }
    return success;
    
}

- (BOOL)addOperations:(NSArray<VDSOperation *> *)operations
                error:(NSError *__autoreleasing  _Nullable *)error
{
    BOOL success = YES;
    
    for (VDSOperation* operation in operations) {
        success = [self addOperation:operation
                               error:error];
        if (success == NO) break;
    }
    
    return success;

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

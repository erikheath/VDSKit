//
//  VDSOperation.m
//  VDSKit
//
//  Created by Erikheath Thomas on 4/22/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import "VDSOperation.h"

#pragma mark - VDSOperationCondition -

@implementation VDSOperationCondition

+ (BOOL)evaluateConditionsForOperation:(VDSOperation* _Nonnull)operation
                                 error:(NSError *__autoreleasing  _Nullable * _Nullable)error
{
    BOOL success = YES;
    NSMutableArray* errorArray = [NSMutableArray new];
    
    for (VDSOperationCondition* condition in operation.conditions) {
        NSError* internalError = nil;
        BOOL satisfied = [condition evaluateForOperation:operation
                                                   error:&internalError];
        if (satisfied == NO) { [errorArray addObject: internalError]; }
    }
    
    if (errorArray.count > 0) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:VDSKitErrorDomain
                                         code:VDSOperationExecutionFailed
                                     userInfo:@{NSUnderlyingErrorKey: [errorArray copy]}];
        }
        success = NO;
    }
    
    return success;
}

+ (NSString*)conditionName { return @"Generic Condition"; }

+ (BOOL)isMutuallyExclusive { return NO; }

- (VDSOperation* _Nullable)dependencyForOperation:(VDSOperation* _Nonnull)operation {
    return nil;
}

- (BOOL)evaluateForOperation:(VDSOperation* _Nonnull)operation
                       error:(NSError *__autoreleasing  _Nullable * _Nullable)error
{
    return YES;
}
@end



#pragma mark - VDSOperation -

@interface VDSOperation ()

@property(readwrite) VDSOperationState state;

@property(strong, readwrite, nonnull) NSArray<VDSOperationCondition*>* conditions;

@property(strong, readwrite, nonnull) NSArray<id<VDSOperationObserver>>* observers;

@property(strong, readwrite, nonnull) NSArray<NSError*>* errors;

@end

@implementation VDSOperation

#pragma mark Properties and KVO Support

@synthesize state = _state;

+ (NSSet*)keyPathsForValuesAffectingIsReady
{
    return [NSSet setWithObject:NSStringFromSelector(@selector(state))];
}

+ (NSSet*)keyPathsForValuesAffectingIsExecuting
{
    return [NSSet setWithObject:NSStringFromSelector(@selector(state))];
}

+ (NSSet*)keyPathsForValuesAffectingIsFinished
{
    return [NSSet setWithObject:NSStringFromSelector(@selector(state))];
}

- (VDSOperationState)state
{
    VDSOperationState currentState;
    [_stateCoordinator lock];
    currentState = _state;
    [_stateCoordinator unlock];
    return currentState;
}

- (void)setState:(VDSOperationState)state
{
    [self willChangeValueForKey:NSStringFromSelector(@selector(state))];
    
    [_stateCoordinator lock];
    if ([self canTransitionToState:state error:nil] == YES) { _state = state; }
    [_stateCoordinator unlock];
    
    [self didChangeValueForKey:NSStringFromSelector(@selector(state))];
}

- (BOOL)isReady
{
    BOOL success = YES;
    
    switch (self.state) {
        case VDSOperationInitialized:
        {
            success = self.isCancelled;
            break;
        }
        case VDSOperationPending:
        {
            if (self.isCancelled == YES) {
                success = YES;
            } else if ([super isReady] == YES) {
                [self evaluateConditions:nil];
                success = NO;
            }
            break;
        }
        case VDSOperationReady:
        {
            success = [super isReady] || [super isCancelled];
            break;
        }
        default:
        {
            success = NO;
            break;
        }
    }
    
    return success;
}

- (BOOL)isExecuting
{
    return self.state == VDSOperationExecuting;
}

- (BOOL)isFinished
{
    return self.state == VDSOperationFinished;
}

#pragma mark Object Lifecycle

- (instancetype)init
{
    self = [super init];
    
    if (self != nil) {
        _state = VDSOperationInitialized;
        _stateCoordinator = [NSLock new];
        _conditions = [NSArray new];
        _observers = [NSArray new];
        _errors = [NSArray new];
    }

    return self;
}

#pragma mark Configuration

- (BOOL)addCondition:(VDSOperationCondition* _Nonnull)condition
               error:(NSError *__autoreleasing  _Nullable *)error
{
    BOOL success = YES;
    
    if(_state < VDSOperationEvaluating) {
        [[self mutableArrayValueForKey:NSStringFromSelector(@selector(conditions))] addObject:condition];
    } else {
        if (error != NULL) {
            *error = [NSError errorWithDomain:VDSKitErrorDomain
                                         code:VDSOperationModificationFailed
                                     userInfo:@{VDSOperationCouldNotModifyOperationErrorKey: VDS_OPERATION_COULD_NOT_ADD_CONDITION_MESSAGE(self.name, condition)}];
        }
        success = NO;
    }
    
    return success;
}

- (BOOL)removeCondition:(VDSOperationCondition *)condition
                  error:(NSError *__autoreleasing  _Nullable *)error
{
    BOOL success = YES;
    
    if(_state < VDSOperationEvaluating) {
        [[self mutableArrayValueForKey:NSStringFromSelector(@selector(conditions))] removeObject:condition];
    } else {
        if (error != NULL) {
            *error = [NSError errorWithDomain:VDSKitErrorDomain
                                         code:VDSOperationModificationFailed
                                     userInfo:@{VDSOperationCouldNotModifyOperationErrorKey: VDS_OPERATION_COULD_NOT_REMOVE_CONDITION_MESSAGE(self.name, condition)}];
        }
        success = NO;
    }
    
    return success;
}

- (BOOL)addObserver:(id<VDSOperationObserver>)observer
              error:(NSError *__autoreleasing  _Nullable *)error
{
    BOOL success = YES;
    
    if(_state < VDSOperationExecuting) {
        [[self mutableArrayValueForKey:NSStringFromSelector(@selector(observers))] addObject:observer];
    } else {
        if (error != NULL) {
            *error = [NSError errorWithDomain:VDSKitErrorDomain
                                         code:VDSOperationModificationFailed
                                     userInfo:@{VDSOperationCouldNotModifyOperationErrorKey: VDS_OPERATION_COULD_NOT_ADD_OBSERVER_MESSAGE(self.name, observer)}];
        }
        success = NO;
    }
    
    return success;
}

- (BOOL)removeObserver:(id)observer
                 error:(NSError *__autoreleasing  _Nullable *)error
{
    BOOL success = YES;
    
    if(_state < VDSOperationExecuting) {
        [[self mutableArrayValueForKey:NSStringFromSelector(@selector(observers))] removeObject:observer];
    } else {
        if (error != NULL) {
            *error = [NSError errorWithDomain:VDSKitErrorDomain
                                         code:VDSOperationModificationFailed
                                     userInfo:@{VDSOperationCouldNotModifyOperationErrorKey: VDS_OPERATION_COULD_NOT_REMOVE_OBSERVER_MESSAGE(self.name, observer)}];
        }
        success = NO;
    }
    
    return success;
}

- (void)addCompletionBlock:(void (^)(void))completionBlock
{
    VDSOperation* __weak weakSelf = self;
    if (self.completionBlock != nil) {
        weakSelf.completionBlock = ^{
            weakSelf.completionBlock();
            completionBlock();
        };
    } else {
        self.completionBlock = completionBlock;
    }
}

- (void)addDependency:(NSOperation*)op
{
    if(_state < VDSOperationExecuting) {
        [super addDependency:op];
    }
}


- (BOOL)addDependency:(VDSOperation*)operation
                error:(NSError* __autoreleasing _Nullable * _Nullable)error
{
    BOOL success = YES;
    
    if(_state < VDSOperationExecuting) {
        [super addDependency:operation];
    } else {
        if (error != NULL) {
            *error = [NSError errorWithDomain:VDSKitErrorDomain
                                         code:VDSOperationModificationFailed
                                     userInfo:@{VDSOperationCouldNotModifyOperationErrorKey: VDS_OPERATION_COULD_NOT_ADD_DEPENDENCY_MESSAGE(self.name, operation)}];
        }
        success = NO;
    }
    
    return success;
}

- (BOOL)addDependencies:(NSArray<VDSOperation *> *)dependencies
                  error:(NSError *__autoreleasing  _Nullable *)error
{
    BOOL success = YES;
    
    for (VDSOperation* operation in dependencies) {
        success = [self addDependency:operation error:error];
        if (success == NO) break;
    }
    
    return success;
}


#pragma mark Execution

- (BOOL)canTransitionToState:(VDSOperationState)state
                       error:(NSError *__autoreleasing  _Nullable *)error
{
    BOOL success = YES;
    
    if (self.state == VDSOperationInitialized && state == VDSOperationPending) {
        success = YES;
    } else if(self.state == VDSOperationPending && state == VDSOperationEvaluating) {
        success = YES;
    } else if(self.state == VDSOperationEvaluating && state == VDSOperationReady) {
        success = YES;
    } else if(self.state == VDSOperationReady && state == VDSOperationExecuting) {
        success = YES;
    } else if(self.state == VDSOperationReady && state == VDSOperationFinishing) {
        success = YES;
    } else if(self.state == VDSOperationExecuting && state == VDSOperationFinishing) {
        success = YES;
    } else if(self.state == VDSOperationFinishing && state == VDSOperationFinished) {
        success = YES;
    } else {
        if (error != NULL) {
            *error = [NSError errorWithDomain:VDSKitErrorDomain
                                         code:VDSOperationExecutionFailed
                                     userInfo:@{VDSOperationInvalidStateErrorKey: VDS_OPERATION_COULD_NOT_TRANSTION_TO_STATE_MESSAGE(self.name, self.state, state)}];
        }
        success = NO;
    }
    
    return success;
}

- (BOOL)evaluateConditions:(NSError *__autoreleasing  _Nullable *)error
{
    BOOL success = YES;
    
    if (self.state != VDSOperationPending || self.isCancelled == YES) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:VDSKitErrorDomain
                                         code:VDSOperationExecutionFailed
                                     userInfo:@{VDSOperationInvalidStateErrorKey:VDS_OPERATION_COULD_NOT_EVALUATE_CONDITIONS_WITH_STATE_MESSAGE(self.name, self.state)}];
        }
    }
    
    if (success == YES) {
        self.state = VDSOperationEvaluating;
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
            NSError* conditionError = nil;
            if ([VDSOperationCondition evaluateConditionsForOperation:self error:&conditionError] == NO) {
                [[self mutableArrayValueForKey:NSStringFromSelector(@selector(errors))] addObject:conditionError];
            }
            self.state = VDSOperationReady;
        });
    }
    
    return success;
}

- (void)produceOperation:(NSOperation* _Nonnull)operation
{
    for (id<VDSOperationObserver> observer in _observers) {
        [observer operation:self
        didProduceOperation:operation];
    }
}

- (void)willEnqueue:(VDSOperationQueue * _Nonnull)queue
{
    self.state = VDSOperationPending;
}

- (void)start {
    [super start];
    if (self.isCancelled == YES) {
        [self finishWithErrors:nil];
    }
}

- (void)main {
    BOOL success = YES;
    NSError* error = nil;
    
    if (success == YES && self.state != VDSOperationReady) {
        error = [NSError errorWithDomain:VDSKitErrorDomain
                                    code:VDSOperationExecutionFailed
                                userInfo:@{VDSOperationInvalidStateErrorKey:VDS_OPERATION_COULD_NOT_EXECUTE_OPERATION_WITH_STATE_MESSAGE(self.name, self.state)}];
        success = NO;
    }
    
    if (success == YES && self.errors.count == 0 && self.isCancelled == NO) {
        self.state = VDSOperationExecuting;
        
        for (id<VDSOperationObserver>observer in self.observers) {
            [observer operationDidStart:self];
        }
    }
    
    if (success == YES) {
        [self execute];
    } else {
        [self finish:error];
    }
}

- (void)execute {
    [self finishWithErrors:nil];
}

- (void)finish:(NSError *_Nullable)error {
    NSArray* errorArray = nil;
    if (error != nil) {
        errorArray = @[error];
    }
    [self finishWithErrors:errorArray];
}

- (void)finishWithErrors:(NSArray<NSError *> *)errors
{
    self.state = VDSOperationFinishing;
    [[self mutableArrayValueForKey:NSStringFromSelector(@selector(errors))] addObjectsFromArray:errors];
    
    [self finishing];
    
    for (id<VDSOperationObserver> observer in _observers) {
        [observer operationDidFinish:self];
    }
    
    self.state = VDSOperationFinished;
}

- (void)finishing
{
    return;
}

- (void)cancelWithError:(NSError* _Nullable)error
{
    if (error != nil) {
        [[self mutableArrayValueForKey:NSStringFromSelector(@selector(errors))] addObject:error];
    }
    [self cancel];
}


@end

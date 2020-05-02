//
//  VDSOperation.m
//  VDSKit
//
//  Created by Erikheath Thomas on 4/22/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import "VDSOperation.h"
#import <objc/runtime.h>


#pragma mark - NSOperation+VDSOperation -

@implementation NSOperation (VDSOperation)

- (void)addCompletionBlock:(void(^ _Nonnull)(void))block
{
    void(^existingBlock)(void) = self.completionBlock;
    
    if (existingBlock != nil) {
        self.completionBlock = ^{
            existingBlock();
            block();
        };
    } else {
        self.completionBlock = block;
    }
}

@end

#pragma mark - VDSOperationCondition -

@implementation VDSOperationCondition

+ (BOOL)evaluateConditionsForOperation:(VDSOperation* _Nonnull)operation
                                 error:(NSError *__autoreleasing  _Nullable * _Nullable)error
{
    // It is a programmer error to pass a nil operation.
    NSAssert(operation != nil, VDS_NIL_ARGUMENT_MESSAGE(nil, _cmd)); \
    
    // operation must be a VDSOperation or subclass. NSOperations are not compatible.
    NSAssert([operation isKindOfClass:[VDSOperation class]],VDS_UNEXPECTED_ARGUMENT_TYPE_MESSAGE(operation, @"operation", _cmd, NSStringFromClass([VDSOperation class])));

        
    BOOL success = YES;

    if (success) {
        NSMutableArray* errorArray = [NSMutableArray new];
        NSMutableString* failedConditions = [NSMutableString stringWithString:@"\n"];
        
        for (VDSOperationCondition* condition in operation.conditions) {
            NSError* internalError = nil;
            BOOL satisfied = [condition evaluateForOperation:operation
                                                       error:&internalError];
            if (satisfied == NO) {
                [errorArray addObject: internalError];
                [failedConditions appendFormat:@"%@\n", NSStringFromClass([condition class])];
            }
        }
        
        if (errorArray.count > 0) {
            if (error != NULL) {
                *error = [NSError errorWithDomain:VDSKitErrorDomain
                                             code:VDSOperationExecutionFailed
                                         userInfo:@{VDSMultipleErrorsReportErrorKey: [errorArray copy],
                                                    VDSLocationErrorKey: NSStringFromSelector(_cmd),
                                                    VDSLocationParametersErrorKey:@{@"": [operation description], NSDebugDescriptionErrorKey: VDS_OPERATION_COULD_NOT_SATISFY_CONDITION_MESSAGE(operation.name, failedConditions)}
                                         }];
            }
            success = NO;
        }
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
    // It is a programmer error to pass a nil operation.
    NSAssert(operation != nil, VDS_NIL_ARGUMENT_MESSAGE(nil, _cmd)); \

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
    if ([self canTransitionToState:state] == YES) { _state = state; }
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
                [self evaluateConditions];
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

- (void)addCondition:(VDSOperationCondition* _Nonnull)condition
{
    
    // It is a programmer error to pass a nil condition.
    NSAssert(condition != nil, VDS_NIL_ARGUMENT_MESSAGE(nil, _cmd));
     
    // The condition must be a VDSOperationCondition or subclass.
    NSAssert([condition isKindOfClass:[VDSOperationCondition class]], VDS_UNEXPECTED_ARGUMENT_TYPE_MESSAGE(condition, @"condition", _cmd, NSStringFromClass([VDSOperationCondition class])));

    // The operation state must be less than VDSOperationEvaluating to add a condition.
    // If it is not, there is likely a race condition or other programmer error.
    NSAssert(_state < VDSOperationEvaluating, VDS_OPERATION_COULD_NOT_ADD_CONDITION_MESSAGE(self.name, condition));
    
    [[self mutableArrayValueForKey:NSStringFromSelector(@selector(conditions))] addObject:condition];
    
}

- (void)addObserver:(id<VDSOperationObserver> _Nonnull)observer
{
    
    // It is a programmer error to pass a nil condition.
    NSAssert(observer != nil, VDS_NIL_ARGUMENT_MESSAGE(nil, _cmd));
     
    // The observer must be a VDSOperationCondition or subclass.
    NSAssert([observer conformsToProtocol:@protocol(VDSOperationObserver)], VDS_UNEXPECTED_ARGUMENT_TYPE_MESSAGE(observer, @"observer", _cmd, NSStringFromProtocol(@protocol(VDSOperationObserver))));
    
    // The operation state must be less than VDSOperationEvaluating to add an observer.
    // If it is not, there is likely a race condition or other programmer error.
    NSAssert(_state < VDSOperationEvaluating, VDS_OPERATION_COULD_NOT_ADD_OBSERVER_MESSAGE(self.name, observer));

    [[self mutableArrayValueForKey:NSStringFromSelector(@selector(observers))] addObject:observer];

}

- (void)addCompletionBlock:(void (^)(void))completionBlock
{
    // It is a programmer error to pass a nil completionBlock.
    NSAssert(completionBlock != NULL && completionBlock != nil, VDS_NIL_ARGUMENT_MESSAGE(nil, _cmd));

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

- (void)addDependency:(NSOperation*)operation
{
    // It is a programmer error to pass a nil operation.
    NSAssert(operation != nil, VDS_NIL_ARGUMENT_MESSAGE(nil, _cmd));

    // The operation must be a NSOperation or subclass.
    NSAssert([operation isKindOfClass:[NSOperation class]], VDS_UNEXPECTED_ARGUMENT_TYPE_MESSAGE(operation, @"operation", _cmd, NSStringFromClass([NSOperation class])));

    // The operation state must be less than VDSOperationEvaluating to add a dependency.
    // If it is not, there is likely a race condition or other programmer error.
    NSAssert(_state < VDSOperationExecuting, VDS_OPERATION_COULD_NOT_ADD_DEPENDENCY_MESSAGE(self.name, operation.name));
    
    [super addDependency:operation];
}


- (void)addDependencies:(NSArray<NSOperation*> *)dependencies
{
    // It is a programmer error to pass a nil dependencies array.
    NSAssert(dependencies != nil, VDS_NIL_ARGUMENT_MESSAGE(nil, _cmd));

    for (NSOperation* operation in dependencies) {
        [self addDependency:operation];
    }
}


#pragma mark Execution

- (BOOL)canTransitionToState:(VDSOperationState)state
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
        success = NO;
    }
    
    return success;
}

- (void)evaluateConditions
{
    NSAssert(self.state != VDSOperationPending || self.isCancelled == YES, VDS_OPERATION_COULD_NOT_EVALUATE_CONDITIONS_WITH_STATE_MESSAGE(self.name, self.state));
    
    self.state = VDSOperationEvaluating;
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        NSError* conditionError = nil;
        if ([VDSOperationCondition evaluateConditionsForOperation:self error:&conditionError] == NO) {
            [[self mutableArrayValueForKey:NSStringFromSelector(@selector(errors))] addObject:conditionError];
        }
        self.state = VDSOperationReady;
    });
    
}

- (void)produceOperation:(NSOperation* _Nonnull)operation
{
    // It is a programmer error to pass a nil operation.
    NSAssert(operation != nil, VDS_NIL_ARGUMENT_MESSAGE(nil, _cmd));

    for (id<VDSOperationObserver> observer in _observers) {
        [observer operation:self
        didProduceOperation:operation];
    }
    
    [self.delegate operation:self
         didProduceOperation:operation];
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

- (void)main
{
    NSAssert(self.state != VDSOperationReady, VDS_OPERATION_COULD_NOT_EXECUTE_OPERATION_WITH_STATE_MESSAGE(self.name, self.state));
    
    if (self.errors.count == 0 && self.isCancelled == NO) {
        self.state = VDSOperationExecuting;
        
        for (id<VDSOperationObserver>observer in self.observers) {
            [observer operationDidStart:self];
        }
        [self execute];
    } else {
        [self finish:nil];
    }
}

- (void)execute {
    [self finishWithErrors:nil];
}

- (void)finish:(NSError *_Nullable)error
{
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

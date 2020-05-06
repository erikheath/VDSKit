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



#pragma mark - VDSOperation -

@interface VDSOperation ()

@property(readwrite) BOOL enqueued;
@property(strong, readwrite, nonnull) NSArray<VDSOperationCondition*>* conditions;
@property(strong, readwrite, nonnull) NSArray<id<VDSOperationObserver>>* observers;
@property(strong, readwrite, nonnull) NSArray<NSError*>* errors;

@end

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
    
    // It is a programmer error to pass a nil condition.
    NSAssert(condition != nil, VDS_NIL_ARGUMENT_MESSAGE(nil, _cmd));
     
    // The condition must be a VDSOperationCondition or subclass.
    NSAssert([condition isKindOfClass:[VDSOperationCondition class]], VDS_UNEXPECTED_ARGUMENT_TYPE_MESSAGE(condition, @"condition", _cmd, NSStringFromClass([VDSOperationCondition class])));

    // The operation state must be less than VDSOperationEvaluating to add a condition.
    // If it is not, there is likely a race condition or other programmer error.
    NSAssert(!self.enqueued, VDS_OPERATION_COULD_NOT_ADD_CONDITION_MESSAGE(self.name, condition));
    
    [[self mutableArrayValueForKey:NSStringFromSelector(@selector(conditions))] addObject:condition];
    
}

- (void)addObserver:(id<VDSOperationObserver> _Nonnull)observer
{
    
    // It is a programmer error to pass a nil condition.
    NSAssert(observer != nil, VDS_NIL_ARGUMENT_MESSAGE(nil, _cmd));
     
    // The observer must be a VDSOperationObserver or subclass.
    NSAssert([observer conformsToProtocol:@protocol(VDSOperationObserver)], VDS_UNEXPECTED_ARGUMENT_TYPE_MESSAGE(observer, @"observer", _cmd, NSStringFromProtocol(@protocol(VDSOperationObserver))));
    
    // The operation state must be less than VDSOperationEvaluating to add an observer.
    // If it is not, there is likely a race condition or other programmer error.
    NSAssert(!self.enqueued, VDS_OPERATION_COULD_NOT_ADD_OBSERVER_MESSAGE(self.name, observer));

    [[self mutableArrayValueForKey:NSStringFromSelector(@selector(observers))] addObject:observer];

}

- (void)willEnqueue
{
    if (_enqueued == NO) { self.enqueued = YES; }
}

#pragma mark Execution

/// @summary Evaluates the conditions associated with the operation, returning YES if conditions
/// have been satisfied, and NO if they have not been satisfied.
///
/// @throws NSInternalInconsistency exception if conditions are evaluated out of order.
- (void)evaluateConditions
{
    NSError* conditionError = nil;
    if ([VDSOperationCondition evaluateConditionsForOperation:self error:&conditionError] == NO) {
        [[self mutableArrayValueForKey:NSStringFromSelector(@selector(errors))] addObject:conditionError];
    }
}

- (void)start {
    [self evaluateConditions];
    [super start];
    if (self.isCancelled == YES) {
        // If the opertaion is canceled, main will not be called,
        // so finish must be called from here.
        [self finishWithErrors:nil];
    }
}

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
    [[self mutableArrayValueForKey:NSStringFromSelector(@selector(errors))] addObjectsFromArray:errors];
    
    [self finishing];
    
    if ([_delegate respondsToSelector:@selector(operationDidFinish:)]) {
        [_delegate operationDidFinish:self];
    }
    
    for (id<VDSOperationObserver> observer in _observers) {
        [observer operationDidFinish:self];
    }
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

//
//  VDSGroupOperation.m
//  VDSKit
//
//  Created by Erikheath Thomas on 4/30/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import "VDSGroupOperation.h"

@implementation VDSGroupOperation

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
            [_internalQueue addOperation:operation];
        }
    }
    
    return self;
}

- (void)addOperation:(NSOperation* _Nonnull)operation
{
    
    // It is a programmer error to pass a nil operation.
    NSAssert(operation != nil, VDS_NIL_ARGUMENT_MESSAGE(nil, _cmd));
    
    // The operation must be a NSOperation or subclass.
    NSAssert([operation isKindOfClass:[NSOperation class]], VDS_UNEXPECTED_ARGUMENT_TYPE_MESSAGE(operation, @"operation", _cmd, NSStringFromClass([NSOperation class])));
    
    [_internalQueue addOperation:operation];
}

- (void)addOperations:(NSArray<NSOperation*>* _Nonnull)operations
{
    // It is a programmer error to pass a nil operation.
    NSAssert(operations != nil, VDS_NIL_ARGUMENT_MESSAGE(nil, _cmd));
    
    // The operation must be a NSOperation or subclass.
    NSAssert([operations isKindOfClass:[NSArray class]], VDS_UNEXPECTED_ARGUMENT_TYPE_MESSAGE(operations, @"operations", _cmd, NSStringFromClass([NSArray class])));

    for (NSOperation* operation in operations) {
        [self addOperation:operation];
    }
    
}


- (void)operationQueue:(VDSOperationQueue * _Nonnull)queue
       didAddOperation:(NSOperation * _Nonnull)operation {
    return;
}

- (void)operationQueue:(VDSOperationQueue * _Nonnull)queue
    operationDidFinish:(NSOperation * _Nonnull)operation {
    return;
}

- (BOOL)operationQueue:(VDSOperationQueue * _Nonnull)queue
    shouldAddOperation:(NSOperation * _Nonnull)operation {
    BOOL success = YES;
    
    // Once the finish operation begins, no additional operations
    // can be added.
    success = !_finishOperation.isFinished && !_finishOperation.isExecuting;
    
    return success;
}

- (void)operationQueue:(VDSOperationQueue * _Nonnull)queue
      willAddOperation:(NSOperation* _Nonnull)operation {
    
    // All operations should be added as a dependency of the
    // finish operation so that the Group Operation has an
    // end point.
    if (operation != _finishOperation) {
        [_finishOperation addDependency:operation];
    }
    
    // All operations depend on the start operation to execute before
    // they can execute (or even evaluate conditions)
    if (operation != _startOperation) {
        [operation addDependency:_startOperation];
    }

    return;
}


@end

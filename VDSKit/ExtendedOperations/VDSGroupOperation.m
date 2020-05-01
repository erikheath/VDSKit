//
//  VDSGroupOperation.m
//  VDSKit
//
//  Created by Erikheath Thomas on 4/30/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import "VDSGroupOperation.h"
#import "VDSErrorFunctions.h"

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
    return [[VDSGroupOperation alloc] initWithOperations:arguments error:NULL];
}

- (instancetype _Nullable)initWithOperations:(NSArray<NSOperation*>* _Nullable)operations
                                       error:(NSError *__autoreleasing  _Nullable * _Nullable)error
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
            NSError* internalError = nil;
            [_internalQueue addOperation:operation
                                   error:&internalError];
            if (internalError != nil) {
                if (error != NULL) { *error = internalError; }
                self = nil;
                break;
            }
        }
    }
    
    return self;
}

- (BOOL)addOperation:(NSOperation* _Nonnull)operation
               error:(NSError *__autoreleasing  _Nullable * _Nullable)error
{
    VDS_NULLABLE_CHECK(@"opertaion", operation, [NSOperation class], _cmd, error)
    
    return [_internalQueue addOperation:operation
                                  error:error];
}

- (BOOL)addOperations:(NSArray<NSOperation*>* _Nonnull)operations
                error:(NSError *__autoreleasing  _Nullable * _Nullable)error
{
    VDS_NULLABLE_CHECK(@"operations", operations, [NSArray class], _cmd, error)
    
    BOOL success = YES;
    
    for (NSOperation* operation in operations) {
        success = [self addOperation:operation
                               error:error];
        if (success == NO) { break; }
    }
    
    return success;
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

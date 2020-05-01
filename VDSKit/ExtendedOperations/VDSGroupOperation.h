//
//  VDSGroupOperation.h
//  VDSKit
//
//  Created by Erikheath Thomas on 4/30/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import "VDSOperation.h"
#import "VDSOperationQueue.h"

@interface VDSGroupOperation : VDSOperation <VDSOperationQueueDelegate>

@property(strong, readonly, nonnull) VDSOperationQueue* internalQueue;

@property(strong, readonly, nonnull) NSOperation* startOperation;

@property(strong, readonly, nonnull) NSOperation* finishOperation;

+ (instancetype _Nullable)initWithOperations:(NSOperation* _Nullable)operation, ...;

- (instancetype _Nullable)initWithOperations:(NSArray<NSOperation*>* _Nullable)operations
                                       error:(NSError *__autoreleasing  _Nullable * _Nullable)error;

- (BOOL)addOperation:(NSOperation* _Nonnull)operation
               error:(NSError *__autoreleasing  _Nullable * _Nullable)error;

- (BOOL)addOperations:(NSArray<NSOperation*>* _Nonnull)operations
                error:(NSError *__autoreleasing  _Nullable * _Nullable)error;


@end

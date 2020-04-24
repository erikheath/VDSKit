//
//  VDSBlockObserver.m
//  VDSKit
//
//  Created by Erikheath Thomas on 4/24/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import "VDSBlockObserver.h"

@implementation VDSBlockObserver

@synthesize didStartOperationHandler = _didStartOperationHandler;
@synthesize didProduceOperationHandler = _didProduceOperationHandler;
@synthesize didFinishOperationHandler = _didFinishOperationHandler;

- (instancetype)init {
    return nil;
}

- (instancetype _Nonnull)initWithStartOperationHandler:(void (^)(VDSOperation * _Nonnull))startOperationHandler produceOperationHandler:(void (^)(VDSOperation * _Nonnull, NSOperation * _Nonnull))produceOperationHandler finishOperationHandler:(void(^_Nullable)(VDSOperation* _Nonnull))finishOperationHandler {
    self = [super init];
    if (self != nil) {
        _didStartOperationHandler = startOperationHandler;
        _didProduceOperationHandler = produceOperationHandler;
        _didFinishOperationHandler = finishOperationHandler;
    }
    return self;
}


- (void)operationDidStart:(VDSOperation * _Nonnull)operation {
    _didStartOperationHandler(operation);
}

- (void)operation:(VDSOperation* _Nonnull)operation
didProduceOperation:(VDSOperation * _Nonnull)newOperation {
    _didProduceOperationHandler(operation, newOperation);
}

- (void)operationDidFinish:(VDSOperation * _Nonnull)operation {
    _didFinishOperationHandler(operation);
}



@end

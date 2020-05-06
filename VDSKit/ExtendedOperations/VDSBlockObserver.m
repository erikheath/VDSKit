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
@synthesize didFinishOperationHandler = _didFinishOperationHandler;

- (instancetype)init {
    NSAssert(NO, VDS_NIL_ARGUMENT_MESSAGE(nil, _cmd));
    return nil;
}

- (instancetype _Nonnull)initWithStartOperationHandler:(void (^)(VDSOperation * _Nonnull))startOperationHandler  finishOperationHandler:(void(^_Nullable)(VDSOperation* _Nonnull))finishOperationHandler {
    self = [super init];
    if (self != nil) {
        _didStartOperationHandler = startOperationHandler;
        _didFinishOperationHandler = finishOperationHandler;
    }
    return self;
}

- (void)operationDidStart:(VDSOperation * _Nonnull)operation {
    if (_didStartOperationHandler != nil) {
        _didStartOperationHandler(operation);
    }
}

- (void)operationDidFinish:(VDSOperation * _Nonnull)operation {
    if (_didFinishOperationHandler != nil) {
        _didFinishOperationHandler(operation);
    }
}



@end

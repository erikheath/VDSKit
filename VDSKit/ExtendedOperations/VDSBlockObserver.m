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


/// Init is overridden because all properties in this class are readonly
/// and can only be set on init. Because of this, calling init makes
/// no sense, so an assertion is included in an override as a debug
/// warning.
///
- (instancetype)init {
    NSAssert(NO, VDS_NIL_ARGUMENT_MESSAGE(nil, _cmd));
    self = [self initWithStartOperationHandler:nil finishOperationHandler:nil];
    return nil;
}


/// This init method expects at least one of the arguments
/// to be non-nil and as such, will throw an exception or return nil if that is
/// not the case.
///
- (instancetype _Nullable)initWithStartOperationHandler:(void (^)(VDSOperation * _Nonnull))startOperationHandler  finishOperationHandler:(void(^_Nullable)(VDSOperation* _Nonnull))finishOperationHandler {
    
    NSAssert(startOperationHandler != nil || finishOperationHandler != nil, VDS_NIL_ARGUMENT_MESSAGE(nil, _cmd));

    self = startOperationHandler != nil || finishOperationHandler != nil ? [super init] : nil;
    if (self != nil) {
        _didStartOperationHandler = startOperationHandler;
        _didFinishOperationHandler = finishOperationHandler;
    }
    return self;
}


/// This method is called near the beginning of the associated operations
/// execution. Observers should not depend on a specific point of execution
/// or a specific order in which observers are called as this is not guaranteed.
///
/// However, this method will be triggered before the operation begins its
/// task in -(void)execute.
///
- (void)operationDidStart:(VDSOperation * _Nonnull)operation {
    if (_didStartOperationHandler != nil) {
        _didStartOperationHandler(operation);
    }
}


/// This method is called after the task(s) in execute have been completed.
/// Observers should not depend on a specific point of execution
/// or a specific order in which observers are called as this is not guaranteed.
///
/// However, this method will be triggered before the operation completes its
/// task in -(void)finishWithErrors:.
///
- (void)operationDidFinish:(VDSOperation * _Nonnull)operation {
    if (_didFinishOperationHandler != nil) {
        _didFinishOperationHandler(operation);
    }
}



@end

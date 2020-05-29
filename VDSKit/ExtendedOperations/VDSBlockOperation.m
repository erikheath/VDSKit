//
//  VDSBlockOperation.m
//  VDSKit
//
//  Created by Erikheath Thomas on 4/29/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import "VDSBlockOperation.h"

@implementation VDSBlockOperation


/// Init is overridden because all properties in this class are readonly
/// and can only be set when initializing. Because of this, calling
/// -(instancetype)init makes no sense, so an assertion is included
/// in an override as a debug warning.
///
- (instancetype _Nullable)init
{
    NSAssert(NO, VDS_NIL_ARGUMENT_MESSAGE(nil, _cmd));
    id block = nil;
    return [self initWithBlock:block];
}


/// Even if assertions are stripped, this will still return a nil.
///
- (instancetype _Nullable)initWithBlock:(void (^_Nonnull)(void(^ _Nonnull)(void)))block {
    NSAssert(block != nil, VDS_NIL_ARGUMENT_MESSAGE(nil, _cmd));
    
    self = block != nil ? [super init] : nil;
    if (self != nil) {
        _task = [block copy];
    }
    return self;
}


/// Even if assertions are stripped, this will still return a nil.
///
- (instancetype _Nullable)initWithMainQueueBlock:(void (^_Nonnull)(void))block {
    
    NSAssert(block != nil, VDS_NIL_ARGUMENT_MESSAGE(nil, _cmd));

    self = block != nil ? [super init] : nil;
    void(^internalBlock)(void) = [block copy];
    if (self != nil) {
        void(^opBlock)(void(^)(void)) = ^void(void(^continuation)(void)) {
            dispatch_async(dispatch_get_main_queue(), ^{
                internalBlock();
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
                    continuation();
                });
            });
        };
        _task = opBlock;
    }
    return self;
}


- (void)execute {
    if (_task == nil) {
        [self finish:NULL];
    } else {
        _task(^{ [self finish:NULL]; });
    }
    return;
}

@end

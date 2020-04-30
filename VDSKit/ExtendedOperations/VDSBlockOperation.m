//
//  VDSBlockOperation.m
//  VDSKit
//
//  Created by Erikheath Thomas on 4/29/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import "VDSBlockOperation.h"

@implementation VDSBlockOperation

- (instancetype _Nullable)initWithBlock:(void (^_Nullable)(void(^ _Nonnull)(void)))block {
    self = [super init];
    if (self != nil) {
        _mainBlock = block;
    }
    return self;
}

- (instancetype _Nullable)initWithMainQueueBlock:(void (^)(void))block {
    self = [super init];
    if (self != nil) {
        void(^opBlock)(void(^)(void)) = ^void(void(^continuation)(void)) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block();
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
                    continuation();
                });
            });
        };
        _mainBlock = opBlock;
    }
    return self;
}

- (void)execute {
    if (_mainBlock == nil) {
        [self finish:NULL];
    } else {
        _mainBlock(^{ [self finish:NULL]; });
    }
    return;
}

@end

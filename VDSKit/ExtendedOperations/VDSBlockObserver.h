//
//  VDSBlockObserver.h
//  VDSKit
//
//  Created by Erikheath Thomas on 4/24/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDSOperation.h"



@interface VDSBlockObserver : NSObject <VDSOperationObserver>

@property(strong, readonly, nullable) void(^didStartOperationHandler)(VDSOperation* _Nonnull);

@property(strong, readonly, nullable) void(^didProduceOperationHandler)(VDSOperation* _Nonnull, NSOperation* _Nonnull);

@property(strong, readonly, nullable) void(^didFinishOperationHandler)(VDSOperation* _Nonnull);

- (instancetype _Nonnull )initWithStartOperationHandler:(void(^_Nullable)(VDSOperation* _Nonnull startOperation))startOperationHandler
                        produceOperationHandler:(void(^_Nullable)(VDSOperation* _Nonnull originOperation, NSOperation* _Nonnull producedOperation))produceOperationHandler
                         finishOperationHandler:(void(^_Nullable)(VDSOperation* _Nonnull finishOperation))finishOperationHandler;
@end



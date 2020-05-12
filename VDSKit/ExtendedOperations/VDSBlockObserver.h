//
//  VDSBlockObserver.h
//  VDSKit
//
//  Created by Erikheath Thomas on 4/24/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

@import Foundation;

#import "VDSOperation.h"
#import "VDSOperationObserver.h"



@interface VDSBlockObserver : NSObject <VDSOperationObserver>

@property(copy, readonly, nullable) void(^didStartOperationHandler)(VDSOperation* _Nonnull);

@property(copy, readonly, nullable) void(^didFinishOperationHandler)(VDSOperation* _Nonnull);

- (instancetype _Nonnull )initWithStartOperationHandler:(void(^_Nullable)(VDSOperation* _Nonnull startOperation))startOperationHandler
                                 finishOperationHandler:(void(^_Nullable)(VDSOperation* _Nonnull finishOperation))finishOperationHandler;
@end



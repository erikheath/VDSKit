//
//  VDSBlockOperation.h
//  VDSKit
//
//  Created by Erikheath Thomas on 4/29/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import "VDSOperation.h"


@interface VDSBlockOperation : VDSOperation

@property(strong, readonly, nullable)void (^mainBlock)(void(^ _Nonnull continuation)(void));

- (instancetype _Nullable )initWithBlock:(void (^_Nullable)(void(^ _Nonnull continuation)(void)))block;

- (instancetype _Nullable)initWithMainQueueBlock:(void (^ _Nullable)(void))block;

@end


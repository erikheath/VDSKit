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





/// @summary VDSBlockObserver provides an ready-made implementation for adding
/// block based functionality to an operation via observation triggers.
///
/// @discussion The VDSBlockObserver class enables custom functionality to be added
/// to an operation at two trigger points: when the operation starts a task, and when the
/// operation finishes a task. The block based format provides a flexible scaffolding for
/// creating customized opertions without needing to create additional VDSOperation subclasses.
///
@interface VDSBlockObserver : NSObject <VDSOperationObserver>


#pragma mark - Properties

/// A block to execute when the opertion begins execution.
///
@property(copy, readonly, nullable) void(^didStartOperationHandler)(VDSOperation* _Nonnull);

/// A block to execute when the opertion enters its finishing phase.
///
@property(copy, readonly, nullable) void(^didFinishOperationHandler)(VDSOperation* _Nonnull);


#pragma mark - Object Lifecycle

/// @summary Initializes the VDSBlockObserver with an optional start and/or finish handler.
///
/// @discussion The startOperationHandler is executed when the operation processes its
/// observers, typically after the operation's start method is called. The finishOperationHandler
/// is executed after the operation's -(void)execute method has completed and the operation has
/// moved into its -(void)finishWithErrors: method.
///
/// @param startOperationHandler The block to execute when the operation starts.
///
/// @param finishOperationHandler The block to execute when the operation finishes.
///
/// @returns An instance of VDSBlockObserver.
///
- (instancetype _Nonnull )initWithStartOperationHandler:(void(^_Nullable)(VDSOperation* _Nonnull startOperation))startOperationHandler
                                 finishOperationHandler:(void(^_Nullable)(VDSOperation* _Nonnull finishOperation))finishOperationHandler;


@end



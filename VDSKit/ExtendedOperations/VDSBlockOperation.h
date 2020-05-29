//
//  VDSBlockOperation.h
//  VDSKit
//
//  Created by Erikheath Thomas on 4/29/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import "VDSOperation.h"




#pragma mark - VDSBlockOperation -


/// @summary VDSBlockOperation provides a ready-made implementation of VDSOperation whose
/// execution behavior can be customized using a block.
///
/// @discussion in many instances, the behavior needed from an operation is a "one-off", and
/// creating a subclass is unnecessary. For these cases, VDSBlockOperation provides a means of
/// creating an operation with custom functionality without needing to create a subclass. When
/// combined with other block focused classes such as VDSBlockObserver, it is possible to create a
/// VDSBlockOperation that can satisfy even moderately complex scenarios such as executing a task,
/// dynamically setting up and tearing down Key-Value Observer, sending out notifications as a task
/// executes, etc.
///
@interface VDSBlockOperation : VDSOperation

#pragma mark - Properties

/// The block that will be executed by the operation.
///
@property(copy, readonly, nonnull)void (^task)(void(^ _Nonnull continuation)(void));


#pragma mark - Object Lifecycle

/// @summary Initializes the VDSBlockOpertion with a block that takes a continuation block.
///
/// @discussion When initializing the operation with a block, the block must call the
/// continuation block at the end of its exeuction, otherwise, the operation will never
/// finish.
///
/// @param block A block to execute that takes a continuation block. The block must call
/// the continuation block a the end of its execution.
///
/// @returns An initialized VDSBlockOperation, or nil if block is nil.
///
/// @throws If the NS_BLOCK_ASSERTIONS macro is not defined, will throw
/// NSInternalInconsistency exception if block is nil.
///
- (instancetype _Nullable )initWithBlock:(void (^_Nonnull)(void(^ _Nonnull continuation)(void)))block NS_DESIGNATED_INITIALIZER;


/// @summary Initializes the VDSBlockOperation with a block to run on the main thread.
///
/// @summary When initializing the operation with a block, the block should perform
/// as little work as possible on the main thread as this can cause noticible lag in UI
/// performance.
///
/// @param block A block to perform on the main thread.
///
/// @throws If the NS_BLOCK_ASSERTIONS macro is not defined, will throw
/// NSInternalInconsistency exception if block is nil.
///
- (instancetype _Nullable)initWithMainQueueBlock:(void (^ _Nonnull)(void))block NS_DESIGNATED_INITIALIZER;

@end


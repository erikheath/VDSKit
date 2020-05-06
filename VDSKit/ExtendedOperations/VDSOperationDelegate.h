//
//  VDSOperationDelegate.h
//  VDSKit
//
//  Created by Erikheath Thomas on 5/6/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - VDSOperationDelegate -

@protocol VDSOperationDelegate <NSObject>

@optional


/// @summary Notifies the delegate that the operation will begin
/// executing.
///
/// @param operation The operation that will begin execution.
- (void)operationWillStart:(VDSOperation* _Nonnull)operation;


/// Notifies the delegate that the operation is beginning the finishing stage of its
/// execution. This notification happens after the state of the operation moves
/// to VDSOperationFinishing but before the fishinedWithErrors method is called.
///
/// @param operation The operation that will finish executing.
- (void)operationWillFinish:(VDSOperation* _Nonnull)operation;


/// Notifies the delegate that the operation has finished executing. This method is called
/// once the state has moved to VDSOperationFinished, but before any completion handlers have
/// been called.
///
/// @param operation The operation that has finished executing.
- (void)operationDidFinish:(NSOperation* _Nonnull)operation;


@end

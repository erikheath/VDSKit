//
//  VDSOperationDelegate.h
//  VDSKit
//
//  Created by Erikheath Thomas on 5/6/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

@import Foundation;





#pragma mark - VDSOperationDelegate -

/// @summary VDSOperationDelegate provides an interface for customizing
/// the execution behavior of an operation.
///
/// @discussion VDSOperationDelegate provides behavior customization 
/// control points prior to execution, at the beginning of execution,
/// at the end of execution (pre-finishing), and before the
/// operation triggers its completion handlers. When used with
/// with a concrete VDSOperation subclass like VDSBlockOperation,
/// the delegate provides a way to create significant customization
/// without the need to create subclasses of VDSOpertion. In many cases
/// this is a better design strategy than creating numerous one-off
/// subclasses.
///
@protocol VDSOperationDelegate <NSObject>

@optional


/// @summary Notifies the delegate that the operation will begin
/// executing.
///
/// @discussion This notification happens before the operation
/// executes NSOperation's -(void)start method. At this point,
/// additional configuration or cancellation of the operation is
/// possible prior to the main or execute method being called.
///
/// @param operation The operation that will begin execution.
///
- (void)operationWillStart:(VDSOperation* _Nonnull)operation;


/// @summary Notifies the delegate that the operation began
/// executing.
///
/// @discussion This notification happens after main begins but before
/// it has verified that there are no errors and that the operation
/// has not been canceled. At this point, additional configuration
/// or cancellation of the operation is possible prior to the execute
/// method being called.
///
/// @param operation The operation that began execution.
///
- (void)operationDidStart:(VDSOperation* _Nonnull)operation;


/// @summary Notifies the delegate that the operation is beginning the finishing stage of its
/// execution.
///
/// @discussion This notification happens after -(void)finishWithErrors: is
/// called and errors are added to the operations errors array, but before
/// any other action is taken such as calling the -(void)finishing method.
///
/// @param operation The operation that will finish executing.
///
- (void)operationWillFinish:(VDSOperation* _Nonnull)operation;


/// @summary Notifies the delegate that the operation has finished executing.
///
/// @discussion This method is called before any completion handlers and observer
/// notifications have been triggered, but after -(void)finishing method has been
/// called.
///
/// @param operation The operation that has finished executing.
///
- (void)operationDidFinish:(NSOperation* _Nonnull)operation;


@end

//
//  VDSOperationObserver.h
//  VDSKit
//
//  Created by Erikheath Thomas on 5/6/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

@import Foundation;





#pragma mark - VDSOperationObserver Protocol -


/// @summary This protocol defines the two methods observers may implement to be
/// notified about important changes in operation state.
///
/// @discussion Observers can use these methods as a trigger to add
/// and/or remove Key-Value Observers to/from an operation, or perform
/// other necessary tasks.
///
@protocol VDSOperationObserver <NSObject>

@optional

/// @summary Notifies the observer that the operation has started.
///
/// @param operation The operation that produced the new operation.
///
- (void)operationDidStart:(VDSOperation* _Nonnull)operation;


/// @summary Notifies the observer that the operation has finished executing.
///
/// @param operation The operation that has finished executing.
///
- (void)operationDidFinish:(VDSOperation* _Nonnull)operation;


@end

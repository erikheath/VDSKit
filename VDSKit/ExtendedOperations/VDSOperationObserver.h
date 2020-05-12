//
//  VDSOperationObserver.h
//  VDSKit
//
//  Created by Erikheath Thomas on 5/6/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

@import Foundation;


#pragma mark - VDSOperationObserver -

@protocol VDSOperationObserver <NSObject>

@optional

/// Notifies the observer that the operation has started.
/// @param operation The operation that produced the new operation.
- (void)operationDidStart:(VDSOperation* _Nonnull)operation;


/// Notifies the observer that the operation has finished executing.
/// @param operation The operation that has finished executing.
- (void)operationDidFinish:(VDSOperation* _Nonnull)operation;

@end

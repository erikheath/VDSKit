//
//  VDSOperationCondition.h
//  VDSKit
//
//  Created by Erikheath Thomas on 5/6/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

@import Foundation;

#import "VDSOperation.h"





#pragma mark - VDSOperationCondition -

@interface VDSOperationCondition : NSObject


/// @summary This class methods causes each condition to evaluate itself for the
/// operation. It aggregates the results, returning YES if all conditons were
/// satisfied, and NO if any of the conditons went unsatisfied. If a reference to an
/// error object is provided, this method aggregates all errors and provides them under
/// a single aggregation error.
///
/// @param operation The operation whose conditons need to be evaluated.
///
/// @param error An error aggregating any errors during evaluation. Use the return value to know when
/// to check for an error object. A return value of NO will always produce an error object.
///
/// @returns YES if the operation condition(s) was satisfied, otherwise NO.
///
+ (BOOL)evaluateConditionsForOperation:(VDSOperation* _Nonnull)operation
                                 error:(NSError* __autoreleasing _Nullable * _Nullable)error;


#pragma mark - Properties

/// @summary The name of the condition that will be used in error reporting.
///
@property(class, strong, readonly, nonnull) NSString* conditionName;


/// @summary YES if multiple instances of an operation may execute concurrently, NO if only
/// one instance of an operation may execute at any one time.
///
/// @note This affects all VDSOperation instances that are added to any VDSOperationQueue.
///
@property(class, readonly) BOOL isMutuallyExclusive;



#pragma mark - Main Behaviors

/// @summary In many cases, a condition can be satisfied if a dependent operation is run
/// before the conditional operation is run. To accomplish this, a condition can
/// produce an operation that should be added to the conditional operation as a
/// dependency. When the conditional operation's dependencies are run, the condition
/// can be satisfied, enableing the conditional operation to successfully execute.
///
/// @note If multiple operations are needed that can not be automatically produced using
/// conditions, consider using a group operation to create a set of operations that can
/// be produced and run to satisfy the conditional operation.
///
/// @param operation The conditional operation.
/// 
/// @returns An operation than can be added to the conditional operation's dependencies
/// and that, when run, may satisfy the conditional operation's execution requirements.
///
- (NSOperation* _Nullable)dependencyForOperation:(VDSOperation* _Nonnull)operation;


/// @summary This instance method is the override point that enables subclasses to insert
/// evaluation logic, error reporting, and a result for a given condition.
///
/// @param operation The operation whose conditions will be evaluated.
///
/// @param error An error object describing the error. Use the return value to know when
/// to check for an error object. A return value of NO will always produce an error object.
///
/// @returns YES if the condition was satisfied, otherwise NO.
///
/// @throws If the NS_BLOCK_ASSERTIONS macro is not defined, will throw
/// NSInternalInconsistency exception if operation is nil.
///
- (BOOL)evaluateForOperation:(VDSOperation* _Nonnull)operation
                       error:(NSError* __autoreleasing _Nullable * _Nullable)error;



@end

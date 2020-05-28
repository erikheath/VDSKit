//
//  VDSOperationCondition.m
//  VDSKit
//
//  Created by Erikheath Thomas on 5/6/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import "VDSOperationCondition.h"





#pragma mark - VDSOperationCondition -

@implementation VDSOperationCondition


/// The conditionName is used for error reporting.
+ (NSString*)conditionName { return @"Generic Condition"; }


/// If the condition requires an operation to execute exclusively, return YES.
+ (BOOL)isMutuallyExclusive { return NO; }


/// This method's role is to determine whether the condition for an opration
/// to execute have been met or not. When a condition fails, it records an error,
/// ultimately aggregating errors and reporting them to the caller.
///
+ (BOOL)evaluateConditionsForOperation:(VDSOperation* _Nonnull)operation
                                 error:(NSError *__autoreleasing  _Nullable * _Nullable)error
{
    /// It is a programmer error to pass a nil operation.
    ///
    NSAssert(operation != nil, VDS_NIL_ARGUMENT_MESSAGE(nil, _cmd)); \
    
    /// The operation must be a VDSOperation or subclass. NSOperations are not compatible.
    ///
    NSAssert([operation isKindOfClass:[VDSOperation class]],VDS_UNEXPECTED_ARGUMENT_TYPE_MESSAGE(operation, @"operation", _cmd, NSStringFromClass([VDSOperation class])));

        
    BOOL success = YES;

    if (success) {
        NSMutableArray* errorArray = [NSMutableArray new];
        NSMutableString* failedConditions = [NSMutableString stringWithString:@"\n"];
        
        for (VDSOperationCondition* condition in operation.conditions) {
            NSError* internalError = nil;
            BOOL satisfied = [condition evaluateForOperation:operation
                                                       error:&internalError];
            if (satisfied == NO) {
                [errorArray addObject: internalError];
                [failedConditions appendFormat:@"%@\n", NSStringFromClass([condition class])];
            }
        }
        
        if (errorArray.count > 0) {
            if (error != NULL) {
                *error = [NSError errorWithDomain:VDSKitErrorDomain
                                             code:VDSOperationExecutionFailed
                                         userInfo:@{VDSMultipleErrorsReportErrorKey: [errorArray copy],
                                                    VDSLocationErrorKey: NSStringFromSelector(_cmd),
                                                    VDSLocationParametersErrorKey:@{@"": [operation description], NSDebugDescriptionErrorKey: VDS_OPERATION_COULD_NOT_SATISFY_CONDITION_MESSAGE(operation.name, failedConditions)}
                                         }];
            }
            success = NO;
        }
    }
    
    return success;
}


/// Override this method to provide a dependency for a VDSOperationCondition subclass.
- (VDSOperation* _Nullable)dependencyForOperation:(VDSOperation* _Nonnull)operation {
    return nil;
}


/// Override this method to provide evaluation behavior for a VDSOperationCondition subclass.
- (BOOL)evaluateForOperation:(VDSOperation* _Nonnull)operation
                       error:(NSError *__autoreleasing  _Nullable * _Nullable)error
{
    /// It is a programmer error to pass a nil operation.
    NSAssert(operation != nil, VDS_NIL_ARGUMENT_MESSAGE(nil, _cmd));

    return YES;
}
@end

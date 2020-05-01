//
//  VDSMutexCondition.m
//  VDSKit
//
//  Created by Erikheath Thomas on 4/30/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import "VDSMutexCondition.h"

@implementation VDSMutexCondition

+ (NSString* _Nonnull)conditionName
{
    return [NSString stringWithFormat:@"MutuallyExclusive<%@>", NSStringFromClass([self class])];
}

+ (BOOL)isMutuallyExclusive
{
    return YES;
}

- (NSOperation* _Nullable)dependencyForOperation:(VDSOperation* _Nonnull)operation
{
    return nil;
}

- (BOOL)evaluateForOperation:(VDSOperation *)operation
                       error:(NSError *__autoreleasing  _Nullable *)error
{
    return [super evaluateForOperation:operation
                                 error:error];
}

@end

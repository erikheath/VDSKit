//
//  VDSOperationMutexCoordinator.m
//  VDSKit
//
//  Created by Erikheath Thomas on 5/6/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import "VDSOperationMutexCoordinator.h"


#pragma mark - VDSOperationMutexCoordinator -

@interface VDSOperationMutexCoordinator ()

@property(strong, readonly, nonnull) dispatch_queue_t serializer;

@property(strong, readonly, nonnull) NSMutableDictionary* mutexOperations;

@end

@implementation VDSOperationMutexCoordinator

static VDSOperationMutexCoordinator* _sharedCoordinator;

@synthesize serializer = _serializer;
@synthesize mutexOperations = _mutexOperations;

+ (VDSOperationMutexCoordinator*)sharedCoordinator
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedCoordinator = [[VDSOperationMutexCoordinator alloc] init];
    });
    return _sharedCoordinator;
}

- (instancetype)init {
    id __block internalSelf = self;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        internalSelf = [super init];
        if (internalSelf != nil) {
            _serializer = dispatch_queue_create("VDSOperationMutexCoordinator", DISPATCH_QUEUE_SERIAL);
            _mutexOperations = [NSMutableDictionary new];
            _sharedCoordinator = internalSelf;
        }
    });
    return _sharedCoordinator;
}

- (void)addOperation:(VDSOperation *)operation
  forConditionsTypes:(NSArray<NSString*> *)conditionTypes {
    dispatch_sync(_serializer, ^{
        for (NSString* conditionType in conditionTypes) {
            NSMutableArray* operationsForConditionType = self->_mutexOperations[conditionType];
            if (operationsForConditionType == nil) {
                operationsForConditionType = [NSMutableArray new];
                [_mutexOperations setObject:operationsForConditionType
                                     forKey:conditionType];
            }
            VDSOperation* lastOperation = operationsForConditionType.lastObject;
            if (lastOperation != nil) { [operation addDependency:lastOperation]; }
            [operationsForConditionType addObject:operation];
        }
    });
}

- (void)removeOperation:(VDSOperation *)operation
      forConditionTypes:(NSArray<Class> *)conditionTypes {
    dispatch_async(_serializer, ^{
        for (NSString* conditionType in conditionTypes) {
            NSMutableArray* operationsForConditionType = self->_mutexOperations[conditionType];
            [operationsForConditionType removeObject:operation];
        }
    });
}

@end

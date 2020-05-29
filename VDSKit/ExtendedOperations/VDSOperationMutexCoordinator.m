//
//  VDSOperationMutexCoordinator.m
//  VDSKit
//
//  Created by Erikheath Thomas on 5/6/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import "VDSOperationMutexCoordinator.h"





#pragma mark - VDSOperationMutexCoordinator Extension -

@interface VDSOperationMutexCoordinator ()

#pragma mark - Properties

/// A serial queue used to ensure thread safety when adding or removing
/// an operation for a condition type.
///
@property(strong, readonly, nonnull) dispatch_queue_t serializer;


/// The dictionary of mutexed operations constructed as a dictionary of
/// arrays, keyed by condition type.
@property(strong, readonly, nonnull) NSMutableDictionary<NSString*, NSMutableArray*>* mutexOperations;

@end





#pragma mark - VDSOperationMutexCoordinator -

@implementation VDSOperationMutexCoordinator

#pragma mark - Properties

/// The application wide shared coordinator instance.
static VDSOperationMutexCoordinator* _sharedCoordinator;

@synthesize serializer = _serializer;
@synthesize mutexOperations = _mutexOperations;


/// Convenience method for returning the shared coordinator.
+ (VDSOperationMutexCoordinator*)sharedCoordinator
{
    return _sharedCoordinator == nil ? [[VDSOperationMutexCoordinator alloc] init] : _sharedCoordinator;
}



#pragma mark - Object Lifecycle

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

#pragma mark - Configuration Behavior

/// When adding an operation for a condition type, this method first determines
/// whether other operations with the condition already exist. If so, the condition
/// is added to the array of operations for that condition. If not, a new array
/// for the condition is created, and then the operation is added to the new array.
///
/// As conditions are added, each one is set to be dependent on the prior one, creating
/// a dependency queue for each condition type.
///
/// To ensure thread safety, a serializer dispatch queue is used. Note that adding an
/// operation is a synchronous event, so this method will block until it completes its
/// work. This ensures that operations do not begin executing before their conditions have
/// been added to the coordinator.
///
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


/// Once an operation has begun executing, it can be removed from the operation array
/// for each of its condition types. This can be done asynchronously because there are
/// no condition dependencies associated with the operation once it begins executing.
///
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

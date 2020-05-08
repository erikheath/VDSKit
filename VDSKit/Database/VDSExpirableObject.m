//
//  VDSExpirableObject.m
//  VDSKit
//
//  Created by Erikheath Thomas on 5/7/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import "VDSExpirableObject.h"
#import "VDSErrorConstants.h"

static NSString* const expiration = @"expiration";
static NSString* const object = @"object";

@interface VDSExpirableObject () {
    dispatch_once_t _onceToken;
}

/// Overriden to support KVO notifications when expired is set to YES.
@property(readwrite) BOOL expired;

@end

@implementation VDSExpirableObject

+ (BOOL)accessInstanceVariablesDirectly {
    return NO;
}

@synthesize expiration = _expiration;
@synthesize expired = _expired;


- (BOOL)isExpired {
    if (!_expired && [_expiration compare:[NSDate now]] == NSOrderedAscending) {
        self.expired = YES;
    }
    return _expired;
}


/// The expired ivar is set once to YES and then blocked from being
/// changed through this setter. To prevent 'accidental' KVO access
/// of the underlying value, accessInstanceVariablesDirectly is set
/// to NO.
///
- (void)setExpired:(BOOL)expired {
    dispatch_once(&_onceToken, ^{
            _expired = YES;
    });
}

#pragma mark - Object Lifecycle


/// ################DO NOT USE FOR INITIALIZATION##############
///
/// No argument init is not supported for this object type. Attempting
/// to do so should always throw an exception, or if exceptions are
/// turned off, should return nil.
///
/// The warnings regarding null passed to nonnull are suppressed as this
/// is an expected issue.
///
- (instancetype)init
{
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wnonnull"

    return [self initWithExpiration:nil object:nil];
    
    #pragma clang diagnostic pop
}


/// Even if exceptions are turned off, instance creation with
/// incorrect arguments should be blocked to prevent creating
/// ghost objects and/or objects that could cause data corruption.
///
/// This is the designated initializer for the class.
///
- (instancetype _Nonnull)initWithExpiration:(NSDate* _Nonnull)expiration
                                      object:(id _Nonnull)object
{
    NSAssert(expiration != nil, VDS_NIL_ARGUMENT_MESSAGE(@"expiration", _cmd));
    NSAssert(object != nil, VDS_NIL_ARGUMENT_MESSAGE(@"object", _cmd));
    NSAssert([expiration isKindOfClass:[NSDate class]], VDS_UNEXPECTED_ARGUMENT_TYPE_MESSAGE(expiration, @"expiration", _cmd, NSStringFromClass([NSDate class])));
     
    self = [super init];
    if (self != nil && expiration != nil && object != nil && [expiration isKindOfClass:[NSDate class]]) {
        _expiration = expiration;
        _object = object;
    } else {
        self = nil;
    }
    return self;
}


/// Convenience initializer.
///
- (instancetype _Nonnull)initWithConfiguration:(NSDictionary* _Nonnull)configuration
{
    return [self initWithExpiration:configuration[@"expiration"] object:configuration[@"object"]];
}


/// Convenience initializer.
///
+ (instancetype _Nonnull)initWithConfiguration:(NSDictionary* _Nonnull)configuration
{
    return [[VDSExpirableObject alloc] initWithConfiguration:configuration];
}


#pragma mark - Utility Behavior

- (NSUInteger)hash {
    return [_object hash];
}

@end

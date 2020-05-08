//
//  VDSExpirableObject.h
//  VDSKit
//
//  Created by Erikheath Thomas on 5/7/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - VDSExpirableObject -


/// A VDSExpirableObject associates a an expiration date with an object. Typically
/// this is used as a convenient way to track and order objects for time-based
/// processing.
///
/// @discussion For example, a cache could use expirable objects in a
/// time sorted list to quickly determine which objects have expired
/// and therefore are no longer valid when accessed.
///
/// VDSExpirableObject overrides its hash method to enable searching for the
/// object stored in its object property. This enables finding an object using
/// isEquals where either the receiver or comparison object can be the object
/// property instead of a VDSExpriableObject.
///
/// @note VDSExpirableObject does not support archiving objects can expire while
/// archived, leading to VDSExpirableObject instances entering an inconsistent state.
///
@interface VDSExpirableObject : NSObject


/// The date used to indicate when an associated object should expire.
/// This property is not KVO compliant
///
@property(strong, readonly, nonnull) NSDate* expiration;


/// An object whose lifespan is associated with the expiration date. This
/// property is not KVO compliant.
///
@property(strong, readonly, nonnull) id object;


/// Indicates if the object has expired. Once set to YES, this value is fixed,
/// however the value will only change when requested (when read). This property
/// is KVO compliant.
///
/// @note While KVO compliant, this property should not be used to be notified when an instance
/// expires. This is because the notification is only dispatched when the value is read,
/// not when the object actually expires. It is, however, useful for housekeeping purposes
/// such as creating a removal list during other processes.
///
@property(readonly, getter=isExpired) BOOL expired;


/// Creates a VDSExpirableObject that associates a expiration date with
/// an object. Passing a nil expiration or nil object value will cause
/// initialization to fail and will generate an exception.
///
/// @param expiration The date that associated object is set to expire.
///
/// @param object An object whose lifespan is associated with the expiration date.
///
/// @returns An instance of VDSExpirableObject.
///
/// @throws NSInternalInconsistency exception if expiration is nil or of the wrong
/// type, or if object is nil. To prevent exceptions define the NS_BLOCK_ASSERTIONS macro.
///
- (instancetype _Nonnull )initWithExpiration:(NSDate* _Nonnull)expiration
                                       object:(id _Nonnull)object NS_DESIGNATED_INITIALIZER;


/// Creates a VDSExpirableObject using the values associated with keys 'expiration'
/// and 'object'. Use this method to load an archived or deserialized object into
/// an expirable object.
///
/// @param configuration A Dictionary containing keys and values corresponding to
/// 'expiration' and 'object'.
///
/// @returns An instance of VDSExpirableObject.
///
/// @throws NSInternalInconsistency exception if expiration is nil or of the wrong
/// type, or if object is nil. To prevent exceptions define the NS_BLOCK_ASSERTIONS macro.
///
- (instancetype _Nonnull)initWithConfiguration:(NSDictionary* _Nonnull)configuration;


/// Creates a VDSExpirableObject using the values associated with keys 'expiration'
/// and 'object'. Use this method to load an archived or deserialized object into
/// an expirable object. This method is a convenience initializer that calls the
/// instance version.
///
/// @param configuration A Dictionary containing keys and values corresponding to
/// 'expiration' and 'object'.
///
/// @returns An instance of VDSExpirableObject.
///
/// @throws NSInternalInconsistency exception if expiration is nil or of the wrong
/// type, or if object is nil. To prevent exceptions define the NS_BLOCK_ASSERTIONS macro.
///

+ (instancetype _Nonnull)initWithConfiguration:(NSDictionary* _Nonnull)configuration;


/// ################DO NOT USE FOR INITIALIZATION##############
///
/// No argument init is not supported for this object type.
///
/// @warning Attempting to use this method will throw an exception,
/// or if exceptions are turned off, will return nil.
///
- (instancetype _Nullable)init;

@end

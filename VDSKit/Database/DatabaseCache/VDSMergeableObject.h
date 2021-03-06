//
//  VDSMergeableObject.h
//  VDSKit
//
//  Created by Erikheath Thomas on 5/8/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>


/// @summary The VDSMergeableObject protocol provides a mechanism for objects
/// stored in a VDSDatabaseCache to provide merging functionality when
/// object updates occur.
///
/// @discussion During an object update, keys are requested from the
/// incoming object using the (NSArray*)mergeableKeys method which should
/// provide a list of all keys in the updated data that will be applied to
/// the existing cached object.
///
/// Once keys are acquired, (void)mergeValue:forKey: is called
/// on the cached object for each key, retrieving the value from the update
/// object. If the key in the update object corresponds to a nil value, the
/// cached object will remove the value (if dictionary like behavior is supported),
/// or set the value to nil. To keep keys in a dictionary but indicate a null value, use
/// NSNull as the value.
///
@protocol VDSMergeableObject <NSObject>

@required

/// @summary Merges the value for the key into receiver.
///
/// @param value The value that should be merged into receiver.
///
/// @param key The property key that will be used to set the merged
/// value on receiver.
///
- (void)mergeValue:(id _Nullable)value forKey:(NSString* _Nonnull)key;


/// @summary The property keys that correspond to values that will be updated in
/// an updatable object.
///
- (NSArray* _Nonnull)mergeableKeys;
 

@end


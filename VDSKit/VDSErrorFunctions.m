//
//  VDSErrorFunctions.m
//  VDSKit
//
//  Created by Erikheath Thomas on 4/29/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import "VDSErrorFunctions.h"
#import "VDSInputVerifier.h"
#import "VDSErrorConstants.h"
#import <objc/runtime.h>


// These messages are ignored because the types in question are checked
// before use.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"

BOOL strictNonnullCheck(NSString* name, id argument, Class argType, SEL location, NSError** error) {
    if (argument == nil) {
        if (error != NULL) {
        *error = [NSError errorWithDomain: VDSKitErrorDomain
                                     code: VDSUnexpextedObjectType
                                 userInfo: @{VDSLocationErrorKey: NSStringFromSelector(location),
                                             VDSLocationParametersErrorKey: @{name: @"nil"},
                                             NSDebugDescriptionErrorKey: VDS_NIL_KEY_MESSAGE(nil, location)}];
        }
        return NO;
    } else if (!verifyObjectMembership(argument, argType)) {
        if (error != NULL) {
        *error = [NSError errorWithDomain: VDSKitErrorDomain
                                     code: VDSUnexpextedObjectType
                                 userInfo: @{VDSLocationErrorKey: NSStringFromSelector(location),
                                             VDSLocationParametersErrorKey: @{name: argument},
                                             NSDebugDescriptionErrorKey: VDS_UNEXPECTED_ARGUMENT_TYPE_MESSAGE(argument, name, location, argType)}];
        }
        return NO;
    }
    return YES;
}

BOOL nonnullCheck(NSString* name, id argument, Class argType, SEL location, NSError** error) {
    if (argument == nil) {
        if (error != NULL) {
        *error = [NSError errorWithDomain: VDSKitErrorDomain
                                     code: VDSUnexpextedObjectType
                                 userInfo: @{VDSLocationErrorKey: NSStringFromSelector(location),
                                             VDSLocationParametersErrorKey: @{name: @"nil"},
                                             NSDebugDescriptionErrorKey: VDS_NIL_KEY_MESSAGE(nil, location)}];
        }
        return NO;
    } else if (!verifyObjectKind(argument, argType)) {
        if (error != NULL) {
        *error = [NSError errorWithDomain: VDSKitErrorDomain
                                     code: VDSUnexpextedObjectType
                                 userInfo: @{VDSLocationErrorKey: NSStringFromSelector(location),
                                             VDSLocationParametersErrorKey: @{name: argument},
                                             NSDebugDescriptionErrorKey: VDS_UNEXPECTED_ARGUMENT_TYPE_MESSAGE(argument, name, location, argType)}];
        }
        return NO;
    }
    return YES;
}

BOOL strictNullableCheck(NSString* name, id argument, Class argType, SEL location, NSError** error) {
    if (!verifyObjectMembership(argument, argType)) {
        if (error != NULL) {
        *error = [NSError errorWithDomain: VDSKitErrorDomain
                                     code: VDSUnexpextedObjectType
                                 userInfo: @{VDSLocationErrorKey: NSStringFromSelector(location),
                                             VDSLocationParametersErrorKey: @{name: argument},
                                             NSDebugDescriptionErrorKey: VDS_UNEXPECTED_ARGUMENT_TYPE_MESSAGE(argument, name, location, argType)}];
        }
        return NO;
    }
    return YES;
}

BOOL nullableCheck(NSString* name, id argument, Class argType, SEL location, NSError** error) {
    if (!verifyObjectKind(argument, argType)) {
        if (error != NULL) {
        *error = [NSError errorWithDomain: VDSKitErrorDomain
                                     code: VDSUnexpextedObjectType
                                 userInfo: @{VDSLocationErrorKey: NSStringFromSelector(location),
                                             VDSLocationParametersErrorKey: @{name: argument},
                                             NSDebugDescriptionErrorKey: VDS_UNEXPECTED_ARGUMENT_TYPE_MESSAGE(argument, name, location, argType)}];
        }
        return NO;
    }
    return YES;
}

BOOL nullableProtocolCheck(NSString* name, id argument, Protocol* argType, SEL location, NSError** error) {
    if (!verifyProtocolMembership(argument, argType)) {
        if (error != NULL) {
        *error = [NSError errorWithDomain: VDSKitErrorDomain
                                     code: VDSUnexpextedObjectType
                                 userInfo: @{VDSLocationErrorKey: NSStringFromSelector(location),
                                             VDSLocationParametersErrorKey: @{name: argument},
                                             NSDebugDescriptionErrorKey: VDS_UNEXPECTED_ARGUMENT_TYPE_MESSAGE(argument, name, location, argType)}];
        }
        return NO;
    }
    return YES;
}

BOOL nonnullProtocolCheck(NSString* name, id argument, Protocol* argType, SEL location, NSError** error) {
    
    if (!verifyProtocolMembership(argument, argType)) {
        if (error != NULL) {
        *error = [NSError errorWithDomain: VDSKitErrorDomain
                                     code: VDSUnexpextedObjectType
                                 userInfo: @{VDSLocationErrorKey: NSStringFromSelector(location),
                                             VDSLocationParametersErrorKey: @{name: argument},
                                             NSDebugDescriptionErrorKey: VDS_UNEXPECTED_ARGUMENT_TYPE_MESSAGE(argument, name, location, argType)}];
        }
        return NO;
    }
    return YES;
}


#pragma clang diagnostic pop

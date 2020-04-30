//
//  VDSInputVerifierFunctions.m
//  VDSKit
//
//  Created by Erikheath Thomas on 4/29/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import "VDSInputVerifierFunctions.h"
#import <objc/runtime.h>

BOOL verifyNonNil(id argument) {
    return argument != nil ? YES : NO;
}

BOOL verifyObjectKind(id argument, Class objectType) {
    return [argument isKindOfClass:objectType];
}

BOOL verifyObjectMembership(id argument, Class objectType) {
    return object_getClass(argument) == objectType;
}

BOOL verifyProtocolMembership(id argument, Protocol* objectType) {
    return class_conformsToProtocol(object_getClass(argument), objectType);
}


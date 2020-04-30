//
//  VDSInputVerifierFunctions.h
//  VDSKit
//
//  Created by Erikheath Thomas on 4/29/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>


BOOL verifyNonNil(id argument);

BOOL verifyObjectKind(id argument, Class objectType);

BOOL verifyObjectMembership(id argument, Class objectType);

BOOL verifyProtocolMembership(id argument, Protocol* objectType);


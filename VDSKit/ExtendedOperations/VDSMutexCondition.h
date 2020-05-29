//
//  VDSMutexCondition.h
//  VDSKit
//
//  Created by Erikheath Thomas on 4/30/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import "VDSOperationCondition.h"





/// @summary Provides a simple condition that prevents more than one
/// operation of a specific type from executing at any one
/// time.
///
@interface VDSMutexCondition : VDSOperationCondition

@end


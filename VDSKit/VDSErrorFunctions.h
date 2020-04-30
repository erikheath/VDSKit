//
//  VDSErrorFunctions.h
//  VDSKit
//
//  Created by Erikheath Thomas on 4/29/20.
//  Copyright © 2020 Erikheath Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef VDS_ARG_CHECKS

    #define VDS_ARG_CHECKS 1

#endif


#ifndef VDS_STRICT_NONNULL_CHECK

    #ifdef VDS_ARG_CHECKS

        #define VDS_STRICT_NONNULL_CHECK(NAME, ARGUMENT, CLASS, LOCATION, ERROR_PTR) \
        success = strictNonnullCheck(NAME, ARGUMENT, CLASS, LOCATION, ERROR_PTR); \
        if (success == NO) { return success; }

    #else

        #define VDS_STRICT_NONNULL_CHECK(NAME, ARGUMENT, CLASS, LOCATION, ERROR_PTR)

    #endif

#endif

BOOL strictNonnullCheck(NSString* name, id argument, Class argType, SEL location, NSError** error);


#ifndef VDS_NONNULL_CHECK

    #ifdef VDS_ARG_CHECKS

        #define VDS_NONNULL_CHECK(NAME, ARGUMENT, CLASS, LOCATION, ERROR_PTR) \
        success = nonnullCheck(NAME, ARGUMENT, CLASS, LOCATION, ERROR_PTR); \
        if (success == NO) { return success; }

    #else

        #define VDS_NONNULL_CHECK(NAME, ARGUMENT, CLASS, LOCATION, ERROR_PTR)

    #endif

#endif

BOOL nonnullCheck(NSString* name, id argument, Class argType, SEL location, NSError** error);


#ifndef VDS_STRICT_NULLABLE_CHECK

    #ifdef VDS_ARG_CHECKS

        #define VDS_STRICT_NULLABLE_CHECK(NAME, ARGUMENT, CLASS, LOCATION, ERROR_PTR) \
        success = strictNullableCheck(NAME, ARGUMENT, CLASS, LOCATION, ERROR_PTR); \
        if (success == NO) { return success; }

    #else

        #define VDS_STRICT_NULLABLE_CHECK(NAME, ARGUMENT, CLASS, LOCATION, ERROR_PTR)

    #endif

#endif

BOOL strictNullableCheck(NSString* name, id argument, Class argType, SEL location, NSError** error);


#ifndef VDS_NULLABLE_CHECK

    #ifdef VDS_ARG_CHECKS

        #define VDS_NULLABLE_CHECK(NAME, ARGUMENT, CLASS, LOCATION, ERROR_PTR) \
        success = strictNonnullCheck(NAME, ARGUMENT, CLASS, LOCATION, ERROR_PTR); \
        if (success == NO) { return success; }

    #else

        #define VDS_NULLABLE_CHECK(NAME, ARGUMENT, CLASS, LOCATION, ERROR_PTR)

    #endif

#endif

BOOL nullableCheck(NSString* name, id argument, Class argType, SEL location, NSError** error);


#ifndef VDS_NULLABLE_PROTOCOL_CHECK

    #ifdef VDS_ARG_CHECKS

        #define VDS_NULLABLE_PROTOCOL_CHECK(NAME, ARGUMENT, PROTOCOL, LOCATION, ERROR_PTR) \
        success = strictNonnullCheck(NAME, ARGUMENT, PROTOCOL, LOCATION, ERROR_PTR); \
        if (success == NO) { return success; }

    #else

        #define VDS_NULLABLE_PROTOCOL_CHECK(NAME, ARGUMENT, PROTOCOL, LOCATION, ERROR_PTR)

    #endif

#endif

BOOL nullableProtocolCheck(NSString* name, id argument, Protocol* argType, SEL location, NSError** error);


#ifndef VDS_NONNULL_PROTOCOL_CHECK

    #ifdef VDS_ARG_CHECKS

        #define VDS_NONNULL_PROTOCOL_CHECK(NAME, ARGUMENT, PROTOCOL, LOCATION, ERROR_PTR) \
        success = strictNonnullCheck(NAME, ARGUMENT, PROTOCOL, LOCATION, ERROR_PTR); \
        if (success == NO) { return success; }

    #else

        #define VDS_NONNULL_PROTOCOL_CHECK(NAME, ARGUMENT, PROTOCOL, LOCATION, ERROR_PTR)

    #endif

#endif

BOOL nonnullProtocolCheck(NSString* name, id argument, Protocol* argType, SEL location, NSError** error);

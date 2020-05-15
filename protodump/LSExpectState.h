//
//  LSExpectState.h
//  protodump
//
//  Created by Leptos on 4/27/20.
//  Copyright © 2020 Leptos. All rights reserved.
//

#ifndef LSExpectState_h
#define LSExpectState_h

// Do not use `LSInternalStateWithMessage` directly, it doesn't have direct boolean support

/* what's cool about this setup is that it allows the __restrict portion to be
 * an NSString constant, a C char array constant, or absolutely nothing at all.
 *
 * e.g. valid uses:
 * LSInternalStateWithMessage(0);
 * LSInternalStateWithMessage(0, "No");
 * LSInternalStateWithMessage(0, @"No").
 * LSInternalStateWithMessage(0, "No (%d)", 0).
 * LSInternalStateWithMessage(0, @"No (%d)", 0).
 *
 */
#define LSInternalStateWithMessage(_s, ...) \
    (__builtin_expect((_s), 0) ? __assert_rtn(__func__, __FILE__, __LINE__, [[NSString stringWithFormat:@"" __VA_ARGS__] UTF8String]) : (void)0)

/* `state` should be `true` for execution to continue */
#define LSExpectStateWithMessage(state, ...) LSInternalStateWithMessage(!(state), __VA_ARGS__)
/* `state` should be `false` for execution to continue */
#define LSUnexpectedStateWithMessage(state, ...) LSExpectStateWithMessage(!(state), __VA_ARGS__)
/* execution will not continue */
#define LSUnreachableStateWithMessage(...) LSExpectStateWithMessage(0, __VA_ARGS__)


#endif /* LSExpectState_h */

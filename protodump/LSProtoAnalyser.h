//
//  LSProtoAnalyser.h
//  protodump
//
//  Created by Leptos on 12/20/18.
//  Copyright © 2018 Leptos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#import "../protobuf/objectivec/GPBMessage.h"
#import "../protobuf/objectivec/GPBDescriptor.h"

#define LS_PROTO_ANONYMOUS_PACKAGE_DIRECTORY "0_ANONYMOUS_PACKAGE"

// Do not use `LSInternalStateWithMessage` directly, it doesn't have direct boolean support

/* wnat's cool about this setup is that it allows the __restrict portion to be
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
#define LSExpectStateWithMessage(state, ...)      LSInternalStateWithMessage(!(state), __VA_ARGS__)
/* `state` should be `false` for execution to continue */
#define LSUnexpectedStateWithMessage(state, ...)  LSExpectStateWithMessage(!(state), __VA_ARGS__)
/* execution will not continue */
#define LSUnreachableStateWithMessage(...)        LSExpectStateWithMessage(0, __VA_ARGS__)


@interface LSProtoAnalyser : NSObject

@property (class, strong, nonatomic, readonly) LSProtoAnalyser *sharedInstance;

/* this is going to result in top-level message only */
@property (strong, nonatomic, readonly) NSArray<GPBDescriptor *> *messages;
@property (strong, nonatomic, readonly) NSArray<NSString *> *packages;

@property (strong, nonatomic, readonly) NSDictionary<NSString *, NSArray<GPBDescriptor *> *> *containerGraph;
@property (strong, nonatomic, readonly) NSDictionary<NSString *, NSArray<GPBDescriptor *> *> *dependencyGraph;

@property (strong, nonatomic, readonly) NSDictionary<NSString *, GPBDescriptor *> *reverseDependencyLookup;
/*contains every message, unlike the messages property */
@property (strong, nonatomic, readonly) NSDictionary<NSString *, GPBDescriptor *> *fullNameLookup;

/* this is going to result in top-level message only */
- (NSArray<GPBDescriptor *> *)messagesInPackage:(NSString *)package;

- (NSArray<NSString *> *)requiredImportsForMessage:(GPBDescriptor *)message;

- (NSString *)protoNameForMessage:(GPBDescriptor *)message;
- (NSString *)protoName:(GPBDescriptor *)message relativeTo:(GPBDescriptor *)relative;

@end

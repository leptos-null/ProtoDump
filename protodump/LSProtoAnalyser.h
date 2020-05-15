//
//  LSProtoAnalyser.h
//  protodump
//
//  Created by Leptos on 12/20/18.
//  Copyright © 2018 Leptos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#import <protobuf/GPBMessage.h>
#import <protobuf/GPBDescriptor.h>

#import "LSExpectState.h"

#define LS_PROTO_ANONYMOUS_PACKAGE_DIRECTORY "0_ANONYMOUS_PACKAGE"


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

- (NSSet<NSString *> *)requiredImportsForMessage:(GPBDescriptor *)message;

- (NSString *)protoNameForMessage:(GPBDescriptor *)message;
- (NSString *)protoName:(GPBDescriptor *)message relativeTo:(GPBDescriptor *)relative;

@end

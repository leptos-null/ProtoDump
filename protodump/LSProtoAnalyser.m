//
//  LSProtoAnalyser.m
//  protodump
//
//  Created by Leptos on 12/20/18.
//  Copyright © 2018 Leptos. All rights reserved.
//

#import "LSProtoAnalyser.h"

/// @c YES if a and b are the same string,
/// or if @c a and @c b are @c nil
/// or if one is @c nil and the other has a 0 length
static BOOL LSNSStringsAreEqual(NSString *a, NSString *b) {
    if ([a isEqualToString:b]) {
        return YES;
    }
    return (a.length == 0 && b.length == 0);
}

@implementation LSProtoAnalyser

+ (instancetype)sharedInstance {
    static LSProtoAnalyser *ret;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ret = [self new];
    });
    return ret;
}

- (instancetype)init {
    if (self = [super init]) {
        NSMutableDictionary<NSString *, GPBDescriptor *> *fullNameLookup = [NSMutableDictionary dictionary];
        
        NSMutableArray<GPBDescriptor *> *messages = [NSMutableArray array];
        NSMutableArray<NSString *> *packages = [NSMutableArray array];
        
        NSMutableDictionary<NSString *, NSMutableArray *> *containerGraph = [NSMutableDictionary dictionary];
        
        /* key depends on values */
        NSMutableDictionary<NSString *, NSMutableArray<NSString *> *> *dependencyAnalyser = [NSMutableDictionary dictionary];
        NSMutableDictionary<NSString *, NSMutableArray<GPBDescriptor *> *> *dependencyGraph = [NSMutableDictionary dictionary];
        NSMutableDictionary<NSString *, GPBDescriptor *> *reverseDependencyLookup = [NSMutableDictionary dictionary];
        
        unsigned int classCount;
        Class *classes = objc_copyClassList(&classCount);
        
        Class const targetSuperclass = objc_getClass("GPBMessage");
        LSExpectStateWithMessage(targetSuperclass, "Google Protobuf runtime not found");
        
        for (uintptr_t classIndex = 0; classIndex < classCount; classIndex++) {
            Class workingClass = classes[classIndex];
            if (class_getSuperclass(workingClass) == targetSuperclass) {
                GPBDescriptor *message = [workingClass descriptor];
                NSString *messageIdentifier = message.fullName;
                LSExpectStateWithMessage(messageIdentifier, "Message %@ does not have a valid full name", message.name);
                LSUnexpectedStateWithMessage(fullNameLookup[messageIdentifier], @"%@ maps to multiple descriptors", messageIdentifier);
                fullNameLookup[messageIdentifier] = message;
                
                NSString *package = message.file.package;
                LSExpectStateWithMessage(package, "Message %@ does not have a package", message.name);
                if (!package.length) {
                    package = @LS_PROTO_ANONYMOUS_PACKAGE_DIRECTORY;
                }
                if (![packages containsObject:package]) {
                    [packages addObject:package];
                }
                GPBDescriptor *containingType = message.containingType;
                if (containingType) {
                    NSString *containerName = containingType.fullName;
                    if (!containerGraph[containerName]) {
                        containerGraph[containerName] = [NSMutableArray array];
                    }
                    [containerGraph[containerName] addObject:message];
                } else {
                    [messages addObject:message];
                }
                
                dependencyAnalyser[messageIdentifier] = [NSMutableArray array];
                for (GPBFieldDescriptor *fieldDsc in message.fields) {
                    if (fieldDsc.dataType == GPBDataTypeMessage) {
                        GPBDescriptor *fieldMessage = [fieldDsc.msgClass descriptor];
                        NSString *fieldMessageIdentifier = fieldMessage.fullName;
                        if (![self _messageInSameFile:message asMessage:fieldMessage]) {
                            if (![dependencyAnalyser[messageIdentifier] containsObject:fieldMessageIdentifier]) {
                                [dependencyAnalyser[messageIdentifier] addObject:fieldMessageIdentifier];
                            }
                            if ([dependencyAnalyser[fieldMessageIdentifier] containsObject:messageIdentifier]) {
                                LSExpectStateWithMessage(LSNSStringsAreEqual(fieldMessage.file.objcPrefix, message.file.objcPrefix),
                                                         @"objcPrefix does not match (%@, %@)", fieldMessageIdentifier, messageIdentifier);
                                LSExpectStateWithMessage(LSNSStringsAreEqual(fieldMessage.file.package, message.file.package),
                                                         @"package does not match (%@, %@)", fieldMessageIdentifier, messageIdentifier);
                                if (!dependencyGraph[messageIdentifier]) {
                                    dependencyGraph[messageIdentifier] = [NSMutableArray array];
                                }
                                if ([dependencyGraph[messageIdentifier] indexOfObjectIdenticalTo:fieldMessage] == NSNotFound) {
                                    [dependencyGraph[messageIdentifier] addObject:fieldMessage];
                                }
                                LSUnexpectedStateWithMessage(reverseDependencyLookup[fieldMessageIdentifier],
                                                             @"Reverse key already set for %@", fieldMessageIdentifier);
                                reverseDependencyLookup[fieldMessageIdentifier] = message;
                            }
                        }
                    }
                }
            }
        }
        free(classes);
        _fullNameLookup = [fullNameLookup copy];
        
        [messages removeObjectsAtIndexes:[messages indexesOfObjectsPassingTest:^BOOL(GPBDescriptor *message, NSUInteger idx, BOOL *stop) {
            return [reverseDependencyLookup.allKeys containsObject:message.fullName];
        }]];
        _packages = [packages copy];
        _messages = [messages copy];
        
        _containerGraph = [containerGraph copy];
        _dependencyGraph = [dependencyGraph copy]; // [self _linearizeDependecyGraph:dependencyAnalyser];
        _reverseDependencyLookup = [reverseDependencyLookup copy];
    }
    return self;
}

- (NSArray<GPBDescriptor *> *)messagesInPackage:(NSString *)package {
    /* preferably this would be the otherway around inside the loop */
    if ([package isEqualToString:@LS_PROTO_ANONYMOUS_PACKAGE_DIRECTORY]) {
        package = @"";
    }
    NSMutableArray<GPBDescriptor *> *messages = [NSMutableArray array];
    for (GPBDescriptor *message in self.messages) {
        if ([message.file.package isEqualToString:package]) {
            [messages addObject:message];
        }
    }
    return [messages copy];
}

- (NSSet<NSString *> *)requiredImportsForMessage:(GPBDescriptor *)message {
    NSMutableSet<NSString *> *ret = [NSMutableSet set];
    for (GPBFieldDescriptor *fieldDsc in message.fields) {
        if (fieldDsc.dataType == GPBDataTypeMessage) {
            GPBDescriptor *targetMessage = [fieldDsc.msgClass descriptor];
            while (targetMessage.containingType) {
                targetMessage = targetMessage.containingType;
                /* below checks: what about here? */
            }
            /* two parts are required for the dependency patch:
             * - skip trying to import a direct dependency
             * - replace an import for a hidden dependency
             */
            NSArray *dependencyCheck = self.dependencyGraph[message.fullName];
            if (dependencyCheck && [dependencyCheck indexOfObjectIdenticalTo:targetMessage] != NSNotFound) {
                continue;
            }
            if ([self _messageInSameFile:message asMessage:targetMessage]) {
                continue;
            }
            
            GPBDescriptor *reverseLookup = targetMessage;
            while ((reverseLookup = self.reverseDependencyLookup[reverseLookup.fullName])) {
                targetMessage = reverseLookup;
            }
            
            NSString *baseName = [[self protoNameForMessage:targetMessage] stringByAppendingPathExtension:@"proto"];
            NSString *dirName = targetMessage.file.package;
            if (!dirName.length) {
                dirName = @LS_PROTO_ANONYMOUS_PACKAGE_DIRECTORY;
            }
            NSString *importName = [dirName stringByAppendingPathComponent:baseName];
            [ret addObject:importName];
        }
    }
    for (GPBDescriptor *containedMessage in self.containerGraph[message.fullName]) {
        [ret unionSet:[self requiredImportsForMessage:containedMessage]];
    }
    return [ret copy];
}

- (BOOL)_messageInSameFile:(GPBDescriptor *)alpha asMessage:(GPBDescriptor *)beta {
    if (alpha == beta) {
        return YES;
    }
    
    NSString *alphaPackage = alpha.file.package;
    if ([alphaPackage isEqualToString:beta.file.package]) {
        NSString *const componentSeparator = @".";
        NSArray<NSString *> *alphaComps = [alpha.fullName componentsSeparatedByString:componentSeparator];
        NSArray<NSString *> *betaComps = [beta.fullName componentsSeparatedByString:componentSeparator];
        
        NSUInteger index = [[alphaPackage componentsSeparatedByString:componentSeparator] count];
        if (alphaPackage.length == 0) {
            index -= 1; /* there's going to be a dot separator missing */
        }
        
        return [alphaComps[index] isEqualToString:betaComps[index]];
    }
    return NO;
}

- (NSString *)protoName:(GPBDescriptor *)message relativeTo:(GPBDescriptor *)relative {
    if ([message.file.package isEqualToString:relative.file.package]) {
        NSInteger index = message.file.package.length;
        if (index) {
            /* names with package prefixes have dot seperators */
            index++;
        }
        /* todo: improve this */
        return [message.fullName substringFromIndex:index];
    } else {
        return [@"." stringByAppendingString:message.fullName];
    }
}

- (NSString *)protoNameForMessage:(GPBDescriptor *)message {
    NSString *parentName = message.containingType.fullName ?: message.file.package;
    NSInteger index = parentName.length;
    if (index) {
        /* names with package prefixes have dot seperators */
        index++;
    }
    return [message.fullName substringFromIndex:index];
}

@end

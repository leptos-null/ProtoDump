//
//  LSProtoAnalyser.m
//  protodump
//
//  Created by Leptos on 12/20/18.
//  Copyright © 2018 Leptos. All rights reserved.
//

#import "LSProtoAnalyser.h"

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
                                LSExpectStateWithMessage([fieldMessage.file.objcPrefix isEqualToString:message.file.objcPrefix],
                                                         @"objcPrefix does not match (%@, %@)", fieldMessageIdentifier, messageIdentifier);
                                LSExpectStateWithMessage([fieldMessage.file.package isEqualToString:message.file.package],
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
    /* this is morally ambiguous
     * preferably this would be the otherway around inside the loop */
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

- (NSArray<NSString *> *)requiredImportsForMessage:(GPBDescriptor *)message {
    return [[self _importListforMessage:message list:[NSMutableArray array]] copy];
}

- (BOOL)_messageInSameFile:(GPBDescriptor *)alpha asMessage:(GPBDescriptor *)beta {
    if (alpha == beta) {
        return YES;
    }
    
    NSString *alphaPacakge = alpha.file.package;
    if ([alphaPacakge isEqualToString:beta.file.package]) {
        static NSString *const componentSeparator = @".";
        NSArray<NSString *> *alphaComps = [alpha.fullName componentsSeparatedByString:componentSeparator];
        NSArray<NSString *> *betaComps = [beta.fullName componentsSeparatedByString:componentSeparator];
        
        NSUInteger index = [[alphaPacakge componentsSeparatedByString:componentSeparator] count];
        if (alphaPacakge.length == 0) {
            index -= 1; /* there's going to be a dot separator missing */
        }
        
        return [alphaComps[index] isEqualToString:betaComps[index]];
    }
    return NO;
}

- (NSMutableArray<NSString *> *)_importListforMessage:(GPBDescriptor *)message list:(NSMutableArray<NSString *> *)list {
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
            if (![list containsObject:importName]) {
                [list addObject:importName];
            }
        }
    }
    for (GPBDescriptor *containedMessage in self.containerGraph[message.fullName]) {
        /* the reason I decided to internally recycle the list, instead of using a non-mutable,
         * and then addObjectsFromArray is that this can check for duplicates more easily */
        [self _importListforMessage:containedMessage list:list];
    }
    return list;
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
    NSInteger index = (message.containingType.fullName ?: message.file.package).length;
    if (index) {
        /* names with package prefixes have dot seperators */
        index++;
    }
    return [message.fullName substringFromIndex:index];
}

@end

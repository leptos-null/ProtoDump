//
//  protodump.m
//  protodump
//
//  Created by Leptos on 12/16/18.
//  Copyright © 2018 Leptos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libgen.h>
#import "LSProtoAnalyser+LSProtoStringGeneration.h"

static void _addDescriptionsToDescriptors() {
    IMP plainDescriptionImpl = imp_implementationWithBlock(^(GPBDescriptor *self) {
        return [NSString stringWithFormat:@"<%@: %p> fullName: %@, containingType: %@", self.class, self, self.fullName, self.containingType];
    });
    class_replaceMethod(objc_getClass("GPBDescriptor"), @selector(description), plainDescriptionImpl, "@@:");
    
    IMP fieldDescriptionImpl = imp_implementationWithBlock(^(GPBFieldDescriptor *self) {
        return [NSString stringWithFormat:@"<%@: %p> name: %@, number: %u", self.class, self, self.name, self.number];
    });
    class_replaceMethod(objc_getClass("GPBFieldDescriptor"), @selector(description), fieldDescriptionImpl, "@@:");
}

static void __attribute__((constructor)) didLoadWithArgs(int argc, char *argv[]) {
    const char *argOne = argv[1];
    if (!argOne) {
        const char *dyldInsertLibs = "DYLD_INSERT_LIBRARIES";
        printf("Usage: %s=%s path/to/executable <out_directory>\n", dyldInsertLibs, getenv(dyldInsertLibs));
        exit(EXIT_FAILURE);
    }
    
    _addDescriptionsToDescriptors();
    
    CFAbsoluteTime startTime, endTime;
    startTime = CFAbsoluteTimeGetCurrent();
    LSProtoAnalyser *protoAnalyser = LSProtoAnalyser.sharedInstance;
    endTime = CFAbsoluteTimeGetCurrent();
    printf("[Stats] Processed %s in %.2f seconds (%ld messages, %lu packages)\n",
           basename(argv[0]), endTime-startTime, protoAnalyser.messages.count, protoAnalyser.packages.count);
    
    startTime = CFAbsoluteTimeGetCurrent();
    static NSUInteger filesWritten; /* I don't really like __block variables */
    LSUnexpectedStateWithMessage(filesWritten,
                                 "Entry function called more than once, or static variable has been manipulated (%lu)", filesWritten);
    
    for (NSString *package in protoAnalyser.packages) {
        if ([package isEqualToString:@LS_PROTO_ANONYMOUS_PACKAGE_DIRECTORY]) {
            puts("[Warning] Anonymous package found. Messages will be in " LS_PROTO_ANONYMOUS_PACKAGE_DIRECTORY);
        }
        NSString *directory = [@(argOne) stringByAppendingPathComponent:package];
        NSError *dirCreateErr = nil;
        [NSFileManager.defaultManager createDirectoryAtPath:directory withIntermediateDirectories:NO attributes:nil error:&dirCreateErr];
        if (dirCreateErr) {
            printf("[Error] %s\n", dirCreateErr.localizedDescription.UTF8String);
            continue;
        }
        for (GPBDescriptor *message in [protoAnalyser messagesInPackage:package]) {
            NSString *cleanName = [protoAnalyser protoNameForMessage:message];
            NSString *path = [[directory stringByAppendingPathComponent:cleanName] stringByAppendingPathExtension:@"proto"];
            NSString *body = [protoAnalyser protoFileForTopLevelMessage:message];
            [body writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:NULL];
            filesWritten++;
        }
    }
    endTime = CFAbsoluteTimeGetCurrent();
    printf("[Stats] Wrote %lu files in %.2f seconds\n", filesWritten, endTime-startTime);
    
    exit(EXIT_SUCCESS);
}

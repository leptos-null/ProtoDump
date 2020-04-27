//
//  LSProtoAnalyser+LSStringGen.h
//  protodump
//
//  Created by Leptos on 12/20/18.
//  Copyright © 2018 Leptos. All rights reserved.
//

#import "LSProtoAnalyser.h"

@interface LSProtoAnalyser (LSStringGen)

/// Recreate the file.proto a descriptor represents
- (NSString *)protoFileForTopLevelMessage:(GPBDescriptor *)message;

@end

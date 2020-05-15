//
//  LSProtoAnalyser+LSStringGen.m
//  protodump
//
//  Created by Leptos on 12/20/18.
//  Copyright © 2018 Leptos. All rights reserved.
//

#import "LSProtoAnalyser+LSStringGen.h"

@implementation LSProtoAnalyser (LSStringGen)

static NSString *NSStringFromGPBFileSyntax(GPBFileSyntax syntax) {
    NSString *ret = nil;
    switch (syntax) {
        case GPBFileSyntaxUnknown:
            // err?
            break;
        case GPBFileSyntaxProto2:
            ret = @"proto2";
            break;
        case GPBFileSyntaxProto3:
            ret = @"proto3";
            break;
        default:
            LSUnreachableStateWithMessage("Unknown syntax: %d", syntax);
            break;
    }
    return ret;
}

- (NSString *)_indentStringForLevel:(NSUInteger)level {
    static const char spaceByte = ' ';
    static const NSUInteger indentSize = 4;
    const NSUInteger buffSize = indentSize * level;
    
    char *const buff = malloc(buffSize);
    memset(buff, spaceByte, buffSize);
    return [[NSString alloc] initWithBytesNoCopy:buff length:buffSize encoding:NSASCIIStringEncoding freeWhenDone:YES];
}

- (NSString *)_stringValueOfNameForField:(GPBFieldDescriptor *)field message:(GPBDescriptor *)message {
    // https://developers.google.com/protocol-buffers/docs/proto#scalar
    NSString *ret = nil;
    switch (field.dataType) {
        case GPBDataTypeBool:
            ret = @"bool";
            break;
        case GPBDataTypeFixed32:
            ret = @"fixed32";
            break;
        case GPBDataTypeSFixed32:
            ret = @"sfixed32";
            break;
        case GPBDataTypeFloat:
            ret = @"float";
            break;
        case GPBDataTypeFixed64:
            ret = @"fixed64";
            break;
        case GPBDataTypeSFixed64:
            ret = @"sfixed64";
            break;
        case GPBDataTypeDouble:
            ret = @"double";
            break;
        case GPBDataTypeInt32:
            ret = @"int32";
            break;
        case GPBDataTypeInt64:
            ret = @"int64";
            break;
        case GPBDataTypeSInt32:
            ret = @"sint32";
            break;
        case GPBDataTypeSInt64:
            ret = @"sint64";
            break;
        case GPBDataTypeUInt32:
            ret = @"uint32";
            break;
        case GPBDataTypeUInt64:
            ret = @"uint64";
            break;
        case GPBDataTypeBytes:
            ret = @"bytes";
            break;
        case GPBDataTypeString:
            ret = @"string";
            break;
        case GPBDataTypeMessage: {
            ret = [self protoName:[field.msgClass descriptor] relativeTo:message];
        } break;
        case GPBDataTypeGroup:
            ret = @"group";
            break;
        case GPBDataTypeEnum: {
            ret = [@"enum " stringByAppendingString:field.enumDescriptor.name];
        } break;
        default:
            LSUnreachableStateWithMessage("Unknown data type: %d", field.dataType);
            break;
    }
    if (field.fieldType == GPBFieldTypeMap) {
        // https://developers.google.com/protocol-buffers/docs/proto#maps
        NSString *mapValue = nil;
        switch (field.mapKeyDataType) {
            case GPBDataTypeBool:
                mapValue = @"bool";
                break;
            case GPBDataTypeFixed32:
                mapValue = @"fixed32";
                break;
            case GPBDataTypeSFixed32:
                mapValue = @"sfixed32";
                break;
            case GPBDataTypeFixed64:
                mapValue = @"fixed64";
                break;
            case GPBDataTypeSFixed64:
                mapValue = @"sfixed64";
                break;
            case GPBDataTypeInt32:
                mapValue = @"int32";
                break;
            case GPBDataTypeInt64:
                mapValue = @"int64";
                break;
            case GPBDataTypeSInt32:
                mapValue = @"sint32";
                break;
            case GPBDataTypeSInt64:
                mapValue = @"sint64";
                break;
            case GPBDataTypeUInt32:
                mapValue = @"uint32";
                break;
            case GPBDataTypeUInt64:
                mapValue = @"uint64";
                break;
            case GPBDataTypeString:
                mapValue = @"string";
                break;
            default:
                LSUnreachableStateWithMessage("Unsupported map key data type: %d", field.mapKeyDataType);
                break;
        }
        ret = [NSString stringWithFormat:@"map<%@, %@>", mapValue, ret];
    }
    return ret;
}

- (NSString *)_stringValueOfDefaultForField:(GPBFieldDescriptor *)field {
    NSString *ret = nil;
    if (field.hasDefaultValue) {
        switch (field.dataType) {
            case GPBDataTypeBool:
                ret = (field.defaultValue.valueBool) ? @"true" : @"false";
                break;
            case GPBDataTypeFixed32:
                ret = @(field.defaultValue.valueInt32).stringValue;
                break;
            case GPBDataTypeSFixed32:
                ret = @(field.defaultValue.valueInt32).stringValue;
                break;
            case GPBDataTypeFloat:
                ret = @(field.defaultValue.valueFloat).stringValue;
                break;
            case GPBDataTypeFixed64:
                ret = @(field.defaultValue.valueInt64).stringValue;
                break;
            case GPBDataTypeSFixed64:
                ret = @(field.defaultValue.valueInt64).stringValue;
                break;
            case GPBDataTypeDouble:
                ret = @(field.defaultValue.valueDouble).stringValue;
                break;
            case GPBDataTypeEnum:
            case GPBDataTypeInt32:
                ret = @(field.defaultValue.valueInt32).stringValue;
                break;
            case GPBDataTypeInt64:
                ret = @(field.defaultValue.valueInt64).stringValue;
                break;
            case GPBDataTypeSInt32:
                ret = @(field.defaultValue.valueInt32).stringValue;
                break;
            case GPBDataTypeSInt64:
                ret = @(field.defaultValue.valueInt64).stringValue;
                break;
            case GPBDataTypeUInt32:
                ret = @(field.defaultValue.valueUInt32).stringValue;
                break;
            case GPBDataTypeUInt64:
                ret = @(field.defaultValue.valueUInt64).stringValue;
                break;
            case GPBDataTypeBytes:
                /* I think this is correct, but not sure */
                ret = [NSString stringWithFormat:@"\"%s\"", field.defaultValue.valueData.bytes];
                break;
            case GPBDataTypeString:
                ret = [NSString stringWithFormat:@"\"%@\"", field.defaultValue.valueString];
                break;
            case GPBDataTypeMessage:
                LSUnreachableStateWithMessage("GPBDataTypeMessage not supported");
                break;
            case GPBDataTypeGroup:
                LSUnreachableStateWithMessage("GPBDataTypeGroup not supported");
                break;
            default:
                LSUnreachableStateWithMessage("Unknown data type");
                break;
        }
    }
    return ret;
}

- (NSString *)_buildIndependentFieldLine:(GPBFieldDescriptor *)field message:(GPBDescriptor *)message syntax:(GPBFileSyntax)syntax labels:(BOOL)allowsLabels {
    NSMutableString *fieldLine = [NSMutableString string];
    
    if (allowsLabels) {
        if (syntax == GPBFileSyntaxProto2) {
            if (field.required) {
                [fieldLine appendString:@"required "];
            }
            if (field.optional) {
                [fieldLine appendString:@"optional "];
            }
        }
        if (field.fieldType == GPBFieldTypeRepeated) {
            [fieldLine appendString:@"repeated "];
        }
    }
    
    [fieldLine appendFormat:@"%@ %@ = %u", [self _stringValueOfNameForField:field message:message], field.textFormatName, field.number];
    if (field.hasDefaultValue) {
        [fieldLine appendFormat:@" [default = %@]", [self _stringValueOfDefaultForField:field]];
    }
    if (field.packable) {
        [fieldLine appendString:@" [packed=true]"];
    }
    return [fieldLine copy];
}

- (NSString *)_fullFieldLine:(GPBFieldDescriptor *)field message:(GPBDescriptor *)message syntax:(GPBFileSyntax)syntax indent:(NSUInteger)indent labels:(BOOL)allowsLabels {
    return [NSString stringWithFormat:@"%@%@%@", [self _indentStringForLevel:indent],
            [self _buildIndependentFieldLine:field message:message syntax:syntax labels:allowsLabels],
            (field.dataType == GPBDataTypeGroup) ? [self _protoBodyForMessage:[field.msgClass descriptor] indent:indent] : @";\n"];
}
/// Whether a descriptor represents the body of a `group` data type
- (BOOL)_isMesssageGroupDescriptor:(GPBDescriptor *)message {
    BOOL isGroup = NO;
    for (GPBFieldDescriptor *field in message.containingType.fields) {
        if ([field.textFormatName isEqualToString:[self protoNameForMessage:message]]) {
            LSExpectStateWithMessage(field.msgClass == message.messageClass,
                                     "Message (%@) does not match special field name's message (%@)", message.name, field.msgClass);
            LSExpectStateWithMessage(field.dataType == GPBDataTypeGroup, "Special field name match is not a group");
            LSUnexpectedStateWithMessage(isGroup, "Multiple special field name matches (message: %@)", message.containingType.name);
            isGroup = YES;
        }
    }
    return isGroup;
}

- (NSString *)_protoBodyForEnum:(GPBEnumDescriptor *)enumDesc indent:(NSUInteger)indentLevel {
    // the public API (`getValue:forEnumTextFormatName:`) is too slow (n^2)
    Ivar valuesIvar = class_getInstanceVariable(object_getClass(enumDesc), "values_");
    const int32_t *enumValues = *(const int32_t **)(((__bridge void *)enumDesc) + ivar_getOffset(valuesIvar));
    
    uint32_t const enumCount = enumDesc.enumNameCount;
    
    NSMutableString *ret = [NSMutableString string];
    [ret appendFormat:@"%@enum %@ {\n", [self _indentStringForLevel:indentLevel], enumDesc.name];
    for (uint32_t enumIdx = 0; enumIdx < enumCount; enumIdx++) {
        NSString *enumName = [enumDesc getEnumTextFormatNameForIndex:enumIdx];
        [ret appendFormat:@"%@%@ = %" __INT32_FMTd__ ";\n", [self _indentStringForLevel:indentLevel+1], enumName, enumValues[enumIdx]];
    }
    [ret appendFormat:@"%@}", [self _indentStringForLevel:indentLevel]];
    return [ret copy];
}

- (NSString *)_protoBodyForMessage:(GPBDescriptor *)message indent:(NSUInteger)indentLevel {
    NSMutableString *ret = [NSMutableString string];
    
    if (![self _isMesssageGroupDescriptor:message]) {
        [ret appendFormat:@"%@message %@", [self _indentStringForLevel:indentLevel], [self protoNameForMessage:message]];
    }
    [ret appendString: @" {\n"];
    for (GPBDescriptor *containedMessage in self.containerGraph[message.fullName]) {
        if (![self _isMesssageGroupDescriptor:containedMessage]) {
            [ret appendFormat:@"%@\n", [self _protoBodyForMessage:containedMessage indent:indentLevel+1]];
        }
    }
    
    for (GPBOneofDescriptor *oneof in message.oneofs) {
        [ret appendFormat:@"%@oneof %@ {\n", [self _indentStringForLevel:indentLevel+1], oneof.name];
        for (GPBFieldDescriptor *field in oneof.fields) {
            [ret appendString:[self _fullFieldLine:field message:message syntax:message.file.syntax indent:indentLevel+2 labels:NO]];
        }
        [ret appendFormat:@"%@}\n", [self _indentStringForLevel:indentLevel+1]];
    }
    for (GPBFieldDescriptor *field in message.fields) {
        if (!field.containingOneof) {
            [ret appendString:[self _fullFieldLine:field message:message syntax:message.file.syntax indent:indentLevel+1 labels:YES]];
        }
    }
    [ret appendFormat:@"%@}\n", [self _indentStringForLevel:indentLevel]];
    
    for (GPBDescriptor *dep in LSProtoAnalyser.sharedInstance.dependencyGraph[message.fullName]) {
        /* todo: fix this in LSProtoAnalyer */
        // LSExpectStateWithMessage(indentLevel == 0, "Currently this tool only supports top-level messages in calculated dependecies");
        if (indentLevel == 0) {
            [ret appendFormat:@"\n%@", [self _protoBodyForMessage:dep indent:indentLevel]];
        } else {
            // NSLog(@"[Warning] Dependency %@ -> %@", message, dep);
        }
    }

    return [ret copy];
}

- (NSString *)protoFileForTopLevelMessage:(GPBDescriptor *)message {
    NSMutableString *ret = [NSMutableString string];
    
    NSString *protoSyntax = NSStringFromGPBFileSyntax(message.file.syntax);
    if (protoSyntax) {
        [ret appendFormat:@"syntax = \"%@\";\n\n", protoSyntax];
    }
    NSString *package = message.file.package;
    if (package.length) {
        [ret appendFormat:@"package %@;\n", package];
    }
    
    NSString *classPrefix = message.file.objcPrefix;
    if (classPrefix) {
        [ret appendFormat:@"option objc_class_prefix = \"%@\";\n", classPrefix];
    }
    [ret appendString:@"\n"];
    
    NSSet<NSString *> *requiredImports = [self requiredImportsForMessage:message];
    if (requiredImports.count) {
        for (NSString *requiredImport in requiredImports) {
            [ret appendFormat:@"import \"%@\";\n", requiredImport];
        }
        [ret appendString:@"\n"];
    }
    [ret appendString:[self _protoBodyForMessage:message indent:0]];
    
    return [ret copy];
}

@end

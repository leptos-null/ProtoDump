// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: Recurse.proto

// This CPP symbol can be defined to use imports that match up to the framework
// imports needed when using CocoaPods.
#if !defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
 #define GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
 #import <protobuf/GPBProtocolBuffers_RuntimeSupport.h>
#else
 #import "GPBProtocolBuffers_RuntimeSupport.h"
#endif

#import "Recurse.pbobjc.h"
// @@protoc_insertion_point(imports)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#pragma mark - RecurseRoot

@implementation RecurseRoot

// No extensions in the file and no imports, so no need to generate
// +extensionRegistry.

@end

#pragma mark - RecurseRoot_FileDescriptor

static GPBFileDescriptor *RecurseRoot_FileDescriptor(void) {
  // This is called by +initialize so there is no need to worry
  // about thread safety of the singleton.
  static GPBFileDescriptor *descriptor = NULL;
  if (!descriptor) {
    GPB_DEBUG_CHECK_RUNTIME_VERSIONS();
    descriptor = [[GPBFileDescriptor alloc] initWithPackage:@""
                                                     syntax:GPBFileSyntaxProto2];
  }
  return descriptor;
}

#pragma mark - Alpha

@implementation Alpha

@dynamic hasBravo, bravo;
@dynamic hasCharlie, charlie;

typedef struct Alpha__storage_ {
  uint32_t _has_storage_[1];
  Beta *bravo;
  Gamma *charlie;
} Alpha__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "bravo",
        .dataTypeSpecific.className = GPBStringifySymbol(Beta),
        .number = Alpha_FieldNumber_Bravo,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(Alpha__storage_, bravo),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
      {
        .name = "charlie",
        .dataTypeSpecific.className = GPBStringifySymbol(Gamma),
        .number = Alpha_FieldNumber_Charlie,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(Alpha__storage_, charlie),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[Alpha class]
                                     rootClass:[RecurseRoot class]
                                          file:RecurseRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(Alpha__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - Beta

@implementation Beta

@dynamic hasAlfa, alfa;
@dynamic hasCharlie, charlie;

typedef struct Beta__storage_ {
  uint32_t _has_storage_[1];
  Alpha *alfa;
  Gamma *charlie;
} Beta__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "alfa",
        .dataTypeSpecific.className = GPBStringifySymbol(Alpha),
        .number = Beta_FieldNumber_Alfa,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(Beta__storage_, alfa),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
      {
        .name = "charlie",
        .dataTypeSpecific.className = GPBStringifySymbol(Gamma),
        .number = Beta_FieldNumber_Charlie,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(Beta__storage_, charlie),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[Beta class]
                                     rootClass:[RecurseRoot class]
                                          file:RecurseRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(Beta__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

#pragma mark - Gamma

@implementation Gamma

@dynamic hasAlfa, alfa;
@dynamic hasBravo, bravo;

typedef struct Gamma__storage_ {
  uint32_t _has_storage_[1];
  Alpha *alfa;
  Beta *bravo;
} Gamma__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "alfa",
        .dataTypeSpecific.className = GPBStringifySymbol(Alpha),
        .number = Gamma_FieldNumber_Alfa,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(Gamma__storage_, alfa),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
      {
        .name = "bravo",
        .dataTypeSpecific.className = GPBStringifySymbol(Beta),
        .number = Gamma_FieldNumber_Bravo,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(Gamma__storage_, bravo),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[Gamma class]
                                     rootClass:[RecurseRoot class]
                                          file:RecurseRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(Gamma__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    #if defined(DEBUG) && DEBUG
      NSAssert(descriptor == nil, @"Startup recursed!");
    #endif  // DEBUG
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end


#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)

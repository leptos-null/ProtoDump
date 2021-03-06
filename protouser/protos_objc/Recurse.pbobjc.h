// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: Recurse.proto

// This CPP symbol can be defined to use imports that match up to the framework
// imports needed when using CocoaPods.
#if !defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
 #define GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
 #import <protobuf/GPBProtocolBuffers.h>
#else
 #import "GPBProtocolBuffers.h"
#endif

#if GOOGLE_PROTOBUF_OBJC_VERSION < 30002
#error This file was generated by a newer version of protoc which is incompatible with your Protocol Buffer library sources.
#endif
#if 30002 < GOOGLE_PROTOBUF_OBJC_MIN_SUPPORTED_VERSION
#error This file was generated by an older version of protoc which is incompatible with your Protocol Buffer library sources.
#endif

// @@protoc_insertion_point(imports)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

CF_EXTERN_C_BEGIN

@class Alpha;
@class Beta;
@class Gamma;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - RecurseRoot

/**
 * Exposes the extension registry for this file.
 *
 * The base class provides:
 * @code
 *   + (GPBExtensionRegistry *)extensionRegistry;
 * @endcode
 * which is a @c GPBExtensionRegistry that includes all the extensions defined by
 * this file and all files that it depends on.
 **/
@interface RecurseRoot : GPBRootObject
@end

#pragma mark - Alpha

typedef GPB_ENUM(Alpha_FieldNumber) {
  Alpha_FieldNumber_Bravo = 2,
  Alpha_FieldNumber_Charlie = 3,
};

@interface Alpha : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) Beta *bravo;
/** Test to see if @c bravo has been set. */
@property(nonatomic, readwrite) BOOL hasBravo;

@property(nonatomic, readwrite, strong, null_resettable) Gamma *charlie;
/** Test to see if @c charlie has been set. */
@property(nonatomic, readwrite) BOOL hasCharlie;

@end

#pragma mark - Beta

typedef GPB_ENUM(Beta_FieldNumber) {
  Beta_FieldNumber_Alfa = 1,
  Beta_FieldNumber_Charlie = 3,
};

@interface Beta : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) Alpha *alfa;
/** Test to see if @c alfa has been set. */
@property(nonatomic, readwrite) BOOL hasAlfa;

@property(nonatomic, readwrite, strong, null_resettable) Gamma *charlie;
/** Test to see if @c charlie has been set. */
@property(nonatomic, readwrite) BOOL hasCharlie;

@end

#pragma mark - Gamma

typedef GPB_ENUM(Gamma_FieldNumber) {
  Gamma_FieldNumber_Alfa = 1,
  Gamma_FieldNumber_Bravo = 2,
};

@interface Gamma : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) Alpha *alfa;
/** Test to see if @c alfa has been set. */
@property(nonatomic, readwrite) BOOL hasAlfa;

@property(nonatomic, readwrite, strong, null_resettable) Beta *bravo;
/** Test to see if @c bravo has been set. */
@property(nonatomic, readwrite) BOOL hasBravo;

@end

NS_ASSUME_NONNULL_END

CF_EXTERN_C_END

#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)

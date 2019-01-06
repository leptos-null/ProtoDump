## ProtoDump

ProtoDump is a tool used to obtain proto definition files using the Objective-C and Google Protobuf runtimes.

### Usage

`DYLD_INSERT_LIBRARIES=/usr/lib/protodump.dylib ./executable <out_dir>`

### TODO

- Enums (currently the ABI equivalent, `int32`, is used instead)

- Dependecy analysis for children messages (currently children messages aren't able to be found during circular dependecy lookups)

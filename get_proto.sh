#!/bin/bash

mkdir -p protobuf/objectivec
curl -L https://raw.githubusercontent.com/protocolbuffers/protobuf/master/objectivec/GPBMessage.h -o protobuf/objectivec/GPBMessage.h
curl -L https://raw.githubusercontent.com/protocolbuffers/protobuf/master/objectivec/GPBDescriptor.h -o protobuf/objectivec/GPBDescriptor.h
curl -L https://raw.githubusercontent.com/protocolbuffers/protobuf/master/objectivec/GPBRuntimeTypes.h -o protobuf/objectivec/GPBRuntimeTypes.h
curl -L https://raw.githubusercontent.com/protocolbuffers/protobuf/master/objectivec/GPBBootstrap.h -o protobuf/objectivec/GPBBootstrap.h

## This is an alternative version
#
# curl -LO "https://github.com/protocolbuffers/protobuf/releases/download/v3.6.1/protobuf-objectivec-3.6.1.tar.gz"
# tar -xf protobuf-objectivec-3.6.1.tar.gz
# rm protobuf-objectivec-3.6.1.tar.gz

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = protodump
protodump_FILES = $(wildcard protodump/*.m)
protodump_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/library.mk

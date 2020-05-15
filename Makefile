include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = protodump
protodump_FILES = $(wildcard protodump/*.m)
protodump_CFLAGS = -fobjc-arc -IPods/Headers/Public -DPROTODUMP_USE_FILE_SYSTEM=1
protodump_LFLAGS = -no_warn_inits

include $(THEOS_MAKE_PATH)/library.mk

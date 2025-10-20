ODINFLAGS_SIM = -no-type-assert -no-bounds-check -disable-assert -no-rpath -source-code-locations:none -o:speed -disable-red-zone 
ODINFLAGS_DEV = -no-type-assert -no-bounds-check -disable-assert -no-rpath -source-code-locations:none -o:speed -disable-red-zone

HEAP_SIZE      = 8388208
STACK_SIZE     = 61800

# Locate the SDK
SDK = ${PLAYDATE_SDK_PATH}
ifeq ($(SDK),)
	SDK = $(shell egrep '^\s*SDKRoot' ~/.Playdate/config | head -n 1 | cut -c9-)
endif

ifeq ($(SDK),)
	$(error SDK path not found; set ENV value PLAYDATE_SDK_PATH)
endif

detected_OS := $(shell uname -s)
detected_OS := $(strip $(detected_OS))

$(info detected_OS is "$(detected_OS)")

ifeq ($(detected_OS), Linux)
	PDSYM = 
	DYLIB_EXT = so
	PDCFLAGS = -sdkpath $(SDK)
endif

ifeq ($(detected_OS), Darwin)
	PDSYM = $(SDK)/bin/Playdate\ Simulator.app/Contents/MacOS/Playdate\ Simulator
	DYLIB_EXT = dylib
	PDCFLAGS=
endif

TRGT = arm-none-eabi-
GCC:=$(dir $(shell which $(TRGT)gcc))

ifeq ($(GCC),)
GCC = /usr/local/bin/
endif

PDC = $(SDK)/bin/pdc
CC   = $(GCC)$(TRGT)gcc -g3

BUILDDIR  = build
LDSCRIPT = $(patsubst ~%,$(HOME)%,$(SDK)/C_API/buildsupport/link_map.ld)

LDFLAGS  = -nostartfiles -mthumb -mcpu=cortex-m7 -mfloat-abi=hard -mfpu=fpv5-sp-d16 -D__FPU_USED=1 -T$(LDSCRIPT) \
					-Wl,-Map=$(BUILDDIR)/pdex.map,--cref,--gc-sections,--no-warn-mismatch,--emit-relocs,--defsym=__aeabi_unwind_cpp_pr0=0 $(LIBDIR)

#
# makefile rules
#

print-%  : ; @echo $* = $($*)

MKBUILDDIR:
	mkdir -p $(BUILDDIR)/Source

simulator-run: simulator
	exec $(PDSYM) $(PRODUCT)

simulator: simulator-bin $(BUILDDIR)/Source/pdxinfo
	$(PDC) $(PDCFLAGS) $(BUILDDIR)/Source $(PRODUCT)

device: device-bin $(BUILDDIR)/Source/pdxinfo
	$(PDC) $(PDCFLAGS) $(BUILDDIR)/Source $(PRODUCT)

$(BUILDDIR)/Source/pdxinfo: pdxinfo | MKBUILDDIR
	cp pdxinfo $(BUILDDIR)/Source/

simulator-bin: | MKBUILDDIR
	odin build . -build-mode:shared -out:$(BUILDDIR)/Source/pdex.${DYLIB_EXT} \
	-no-entry-point -default-to-nil-allocator -no-thread-local \
	$(ODINFLAGS_SIM)

device-bin: odin-build $(LDSCRIPT) | MKBUILDDIR
	$(CC) $(BUILDDIR)/odin*.o $(LDFLAGS) -o $(BUILDDIR)/Source/pdex.elf

.PHONY: odin-build
odin-build: | MKBUILDDIR
	odin build . -out:$(BUILDDIR)/odin -build-mode:obj -target:freestanding_arm32 -reloc-mode:pic -use-separate-modules \
		-no-entry-point -default-to-nil-allocator -no-thread-local \
		-target-features:armv7e-m,thumb-mode,thumb2,mclass,m7,noarm,hwdiv,dsp,db,fp-armv8d16sp,vfp4d16sp,fpregs,fpregs16,v7,v7clrex,v6m,v6t2,v6k,v6,v5te,v5t,v4t \
		$(ODINFLAGS_DEV)

clean:
	-rm -rf $(BUILDDIR)
	-rm -fR $(PRODUCT)

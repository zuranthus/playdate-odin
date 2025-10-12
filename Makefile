PRODUCT = HelloWorld.pdx

HEAP_SIZE      = 8388208
STACK_SIZE     = 61800

# Odin source files
ODIN_SRC = main.odin


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

  GCCFLAGS = -g
  SIMCOMPILER = gcc $(GCCFLAGS)
  DYLIB_FLAGS = -shared -fPIC
  DYLIB_EXT = so
  PDCFLAGS = -sdkpath $(SDK)
endif

ifeq ($(detected_OS), Darwin)

  CLANGFLAGS = -g
  SIMCOMPILER = clang $(CLANGFLAGS)
  DYLIB_FLAGS = -dynamiclib -rdynamic
  DYLIB_EXT = dylib
  PDCFLAGS=
  # Uncomment to build a binary that works with Address Sanitizer
  #CLANGFLAGS += -fsanitize=address

endif

TRGT = arm-none-eabi-
GCC:=$(dir $(shell which $(TRGT)gcc))

ifeq ($(GCC),)
GCC = /usr/local/bin/
endif

OJBCPY:=$(dir $(shell which $(TRGT)objcopy))

ifeq ($(OJBCPY),)
OJBCPY = /usr/local/bin/
endif

PDC = $(SDK)/bin/pdc

VPATH += $(SDK)/C_API/buildsupport

CC   = $(GCC)$(TRGT)gcc -g3
CP   = $(OJBCPY)$(TRGT)objcopy
AS   = $(GCC)$(TRGT)gcc -x assembler-with-cpp
STRIP= $(GCC)$(TRGT)strip
BIN  = $(CP) -O binary
HEX  = $(CP) -O ihex

MCU  = cortex-m7

# List all default directories to look for include files here
DINCDIR = . $(SDK)/C_API

# List the default directory to look for the libraries here
DLIBDIR =

# List all default libraries here
DLIBS =

OPT = -O2
COPT = $(OPT) -falign-functions=16 -fomit-frame-pointer

#
# Define linker script file here
#
LDSCRIPT = $(patsubst ~%,$(HOME)%,$(SDK)/C_API/buildsupport/link_map.ld)

#
# Define FPU settings here
#
FPU = -mfloat-abi=hard -mfpu=fpv5-sp-d16 -D__FPU_USED=1

INCDIR  = $(patsubst %,-I %,$(DINCDIR) $(UINCDIR))
LIBDIR  = $(patsubst %,-L %,$(DLIBDIR) $(ULIBDIR))
BUILDDIR  = build

DEFS	= $(DDEFS) $(UDEFS)

LIBS	= $(DLIBS) $(ULIBS)
MCFLAGS = -mthumb -mcpu=$(MCU) $(FPU)

ODINFLAGS = -no-bounds-check -disable-assert -no-crt -no-entry-point -no-rpath -no-thread-local -source-code-locations:none

CPFLAGS  = $(MCFLAGS) $(COPT) -gdwarf-2 -Wall -Wno-unused -Wstrict-prototypes -Wno-unknown-pragmas -fverbose-asm -Wdouble-promotion -mword-relocations -fno-common
CPFLAGS += -ffunction-sections -fdata-sections -Wa,-ahlms=$(BUILDDIR)/$(notdir $(<:.c=.lst)) -DTARGET_PLAYDATE=1 -DTARGET_EXTENSION=1

LLC_FLAGS = $(OPT) -mtriple=thumbv7em-none-eabihf -mcpu=$(MCU) -mattr=+fp-armv8d16sp -float-abi=hard -relocation-model=pic

LDFLAGS  = -nostartfiles $(MCFLAGS) -T$(LDSCRIPT) -Wl,-Map=$(BUILDDIR)/pdex.map,--cref,--gc-sections,--no-warn-mismatch,--emit-relocs,--defsym=__exidx_start=0,--defsym=__exidx_end=0,--defsym=_exit=0,--defsym=_kill=0,--defsym=_getpid=0 $(LIBDIR)

# Odin object files
ODIN_OBJ_FILES = $(BUILDDIR)/odin-main.o $(BUILDDIR)/odin-builtin.o $(BUILDDIR)/odin-runtime-core.o $(BUILDDIR)/odin-runtime-internal.o $(BUILDDIR)/odin-runtime-procs.o $(BUILDDIR)/odin-runtime-default_allocators_nil.o $(BUILDDIR)/odin-runtime-random_generator.o

#
# makefile rules
#

print-%  : ; @echo $* = $($*)

MKBUILDDIR:
	mkdir -p $(BUILDDIR)/Source

$(BUILDDIR)/Source/pdxinfo: pdxinfo | MKBUILDDIR
	cp pdxinfo $(BUILDDIR)/Source/

simulator: simulator_bin $(BUILDDIR)/Source/pdxinfo
	$(PDC) $(PDCFLAGS) $(BUILDDIR)/Source $(PRODUCT)

simulator_bin: | MKBUILDDIR
	odin build . -build-mode:shared -out:$(BUILDDIR)/Source/pdex.${DYLIB_EXT} -default-to-nil-allocator

device: device_bin $(BUILDDIR)/Source/pdxinfo
	$(PDC) $(PDCFLAGS) $(BUILDDIR)/Source $(PRODUCT)

device_bin: $(BUILDDIR)/setup.o odin_objs $(LDSCRIPT) | MKBUILDDIR
	$(CC) $(BUILDDIR)/setup.o $(ODIN_OBJ_FILES) $(LDFLAGS) $(LIBS) -o $(BUILDDIR)/Source/pdex.elf

$(BUILDDIR)/setup.o: $(SDK)/C_API/buildsupport/setup.c | MKBUILDDIR
	$(CC) -c $(CPFLAGS) -I . $(INCDIR) $< -o $@

.PHONY: odin_objs
odin_objs: | MKBUILDDIR
	odin build . -out:odin -o:none -build-mode:llvm-ir -target:freestanding_arm32 -default-to-nil-allocator $(ODINFLAGS) 
	mv -f *.ll $(BUILDDIR)/
	for ll in $(BUILDDIR)/*.ll; do \
		llc $(LLC_FLAGS) -filetype=obj -o $${ll%.ll}.o $$ll; \
	done

clean:
	-rm -rf $(BUILDDIR)
	-rm -fR $(PRODUCT)

# *** EOF ***

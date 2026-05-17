ifeq ($(PRODUCT),)
$(error PRODUCT is not set. Please set PRODUCT in your Makefile before including this file)
endif

BUILD ?= debug

ODINFLAGS_COMMON ?= -no-rpath -disable-red-zone -vet -strict-style -vet-tabs -disallow-do -warnings-as-errors

ifeq ($(BUILD),debug)
ODINFLAGS_BUILD_SIM    ?= -debug
ODINFLAGS_BUILD_DEVICE ?= -o:speed
else ifeq ($(BUILD),release)
ODINFLAGS_BUILD_SIM    ?= -no-type-assert -no-bounds-check -disable-assert -source-code-locations:none -o:speed
ODINFLAGS_BUILD_DEVICE ?= -no-type-assert -no-bounds-check -disable-assert -source-code-locations:none -o:speed
else
$(error BUILD must be 'debug' or 'release' (got '$(BUILD)'))
endif

ODINFLAGS_SIM    ?= $(ODINFLAGS_COMMON) $(ODINFLAGS_BUILD_SIM)
ODINFLAGS_DEVICE ?= $(ODINFLAGS_COMMON) $(ODINFLAGS_BUILD_DEVICE)

HEAP_SIZE       ?= 8388208
STACK_SIZE      ?= 61800
TEMP_ARENA_SIZE ?= 65536

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
PD_DEVICE ?= $(firstword $(wildcard /dev/cu.usbmodemPDU*))
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
PLAYDATE_BUILD_DIR = $(dir $(lastword $(MAKEFILE_LIST)))
LDSCRIPT = $(PLAYDATE_BUILD_DIR)link_map.ld

LDFLAGS  = -nostartfiles -mthumb -mcpu=cortex-m7 -mfloat-abi=hard -mfpu=fpv5-sp-d16 -D__FPU_USED=1 -T$(LDSCRIPT) \
					-Wl,-Map=$(BUILDDIR)/pdex.map,--cref,--gc-sections,--no-warn-mismatch,--emit-relocs,--defsym=__aeabi_unwind_cpp_pr0=0,--defsym=__aeabi_unwind_cpp_pr1=0,--defsym=__aeabi_d2h=0 $(LIBDIR)

#
# makefile rules
#

print-%  : ; @echo $* = $($*)

MKBUILDDIR:
	mkdir -p $(BUILDDIR)/Source

simulator: simulator-bin $(BUILDDIR)/Source/pdxinfo
	$(PDC) $(PDCFLAGS) $(BUILDDIR)/Source $(PRODUCT)

device: device-bin $(BUILDDIR)/Source/pdxinfo
	$(PDC) $(PDCFLAGS) $(BUILDDIR)/Source $(PRODUCT)

$(BUILDDIR)/Source/pdxinfo: pdxinfo | MKBUILDDIR
	cp pdxinfo $(BUILDDIR)/Source/

simulator-bin: | MKBUILDDIR
	odin build . -build-mode:shared -out:$(BUILDDIR)/Source/pdex.${DYLIB_EXT} \
	-no-entry-point -default-to-nil-allocator -no-thread-local \
	-define:PLAYDATE_TEMP_ARENA_SIZE=$(TEMP_ARENA_SIZE) \
	$(ODINFLAGS_SIM)

device-bin: odin-build $(LDSCRIPT) | MKBUILDDIR
	$(CC) $(BUILDDIR)/odin*.o $(LDFLAGS) -o $(BUILDDIR)/Source/pdex.elf

.PHONY: odin-build
odin-build: | MKBUILDDIR
	odin build . -out:$(BUILDDIR)/odin -build-mode:obj -target:freestanding_arm32 -reloc-mode:pic \
		-no-entry-point -default-to-nil-allocator -no-thread-local \
		-target-features:armv7e-m,thumb-mode,thumb2,mclass,m7,noarm,hwdiv,dsp,db,fp-armv8d16sp,vfp4d16sp,fpregs,fpregs16,v7,v7clrex,v6m,v6t2,v6k,v6,v5te,v5t,v4t \
		-define:PLAYDATE_TEMP_ARENA_SIZE=$(TEMP_ARENA_SIZE) \
		$(ODINFLAGS_DEVICE)

clean:
	-rm -rf $(BUILDDIR)
	-rm -fR $(PRODUCT)

.PHONY: fmt
fmt:
	odinfmt -w .

ifeq ($(detected_OS), Darwin)
.PHONY: device-deploy
device-deploy: device
	@test -n "$(PD_DEVICE)" || { echo "No Playdate found (expected /dev/cu.usbmodemPDU*)"; exit 1; }
	$(SDK)/bin/pdutil $(PD_DEVICE) datadisk
	@until [ -d /Volumes/PLAYDATE/Games ]; do sleep 1; done
	cp -R $(PRODUCT) /Volumes/PLAYDATE/Games/
	diskutil eject /Volumes/PLAYDATE
	@until [ -e $(PD_DEVICE) ]; do sleep 1; done
	$(SDK)/bin/pdutil $(PD_DEVICE) run /Games/$(PRODUCT)

# simulator-run and device-run both clear ISIG on the controlling tty so
# Ctrl-C arrives as the byte 0x03 in stdin instead of as SIGINT, then poll
# stdin for a quit byte while the child runs in the background. The trap
# cleans up regardless of how the script exits (quit byte, child died, etc).

define SIMULATOR_RUN_SCRIPT
orig=$$(stty -g)
cleanup() {
  stty "$$orig" 2>/dev/null
  osascript -e 'tell application "Playdate Simulator" to quit' >/dev/null 2>&1
}
trap cleanup EXIT
stty -icanon -echo -isig min 1 time 0
"$$1" "$$2" & p=$$!
while kill -0 $$p 2>/dev/null; do
  IFS= read -t 1 -rsn1 c && case "$$c" in $$'\x03'|$$'\x1b'|q|Q) break;; esac
done
endef
export SIMULATOR_RUN_SCRIPT

.PHONY: simulator-run
simulator-run: simulator
	@echo "Running $(PRODUCT) in Simulator (Ctrl-C, q, or ESC to stop)"
	-@bash -c "$$SIMULATOR_RUN_SCRIPT" _ $(PDSYM) $(PRODUCT)

define DEVICE_RUN_SCRIPT
orig=$$(stty -g)
trap 'stty "$$orig" 2>/dev/null; kill -9 $$p 2>/dev/null' EXIT
stty -icanon -echo -isig min 1 time 0
cat "$$1" & p=$$!
while kill -0 $$p 2>/dev/null; do
  IFS= read -t 1 -rsn1 c && case "$$c" in $$'\x03'|$$'\x1b'|q|Q) break;; esac
done
endef
export DEVICE_RUN_SCRIPT

.PHONY: device-run
device-run: device-deploy
	@echo "Tailing $(PD_DEVICE) (Ctrl-C, q, or ESC to stop)"
	-@bash -c "$$DEVICE_RUN_SCRIPT" _ $(PD_DEVICE)
endif

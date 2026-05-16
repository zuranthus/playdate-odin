PRODUCT = OdinTests.pdx

ODINFLAGS_SIM ?= -no-rpath -o:speed -disable-red-zone -vet -strict-style -vet-tabs -disallow-do -warnings-as-errors
ODINFLAGS_DEV ?= -no-rpath -o:speed -disable-red-zone -vet -strict-style -vet-tabs -disallow-do -warnings-as-errors

include ../playdate/buildsupport/Makefile.inc

ifneq ($(TEST_FILTER),)
ODINFLAGS_SIM += -define:TEST_FILTER=\"$(TEST_FILTER)\"
ODINFLAGS_DEV += -define:TEST_FILTER=\"$(TEST_FILTER)\"
endif

PD_DEVICE ?= $(firstword $(wildcard /dev/cu.usbmodemPDU*))

.PHONY: test-device
test-device: device
	@test -n "$(PD_DEVICE)" || { echo "No Playdate found (expected /dev/cu.usbmodemPDU*)"; exit 1; }
	$(SDK)/bin/pdutil $(PD_DEVICE) datadisk
	@until [ -d /Volumes/PLAYDATE/Games ]; do sleep 1; done
	cp -R $(PRODUCT) /Volumes/PLAYDATE/Games/
	diskutil eject /Volumes/PLAYDATE
	@until [ -e $(PD_DEVICE) ]; do sleep 1; done
	$(SDK)/bin/pdutil $(PD_DEVICE) run /Games/$(PRODUCT)
	awk '/=== DONE ===/{exit} {print}' < $(PD_DEVICE)

.PHONY: test-sim
test-sim: simulator
	script -q /dev/null $(PDSYM) $(PRODUCT) 2>&1 | awk '/=== DONE ===/{ system("osascript -e \"tell application \\\"Playdate Simulator\\\" to quit\""); exit } { print }'

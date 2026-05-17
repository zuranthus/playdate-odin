PRODUCT = OdinTests.pdx

include ../playdate/buildsupport/Makefile.inc

ifneq ($(TEST_FILTER),)
ODINFLAGS_SIM    += -define:TEST_FILTER=\"$(TEST_FILTER)\"
ODINFLAGS_DEVICE += -define:TEST_FILTER=\"$(TEST_FILTER)\"
endif

.PHONY: test-device
test-device: device-deploy
	awk '/=== DONE ===/{exit} {print}' < $(PD_DEVICE)

.PHONY: test-sim
test-sim: simulator
	script -q /dev/null $(PDSYM) $(PRODUCT) 2>&1 | awk '/=== DONE ===/{ system("osascript -e \"tell application \\\"Playdate Simulator\\\" to quit\""); exit } { print }'

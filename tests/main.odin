package test

import playdate "../playdate"

@(export)
eventHandler :: proc "c" (pd: ^playdate.API, event: playdate.PDSystemEvent, arg: i32) -> i32 {
	context = playdate.default_context(pd)
	#partial switch event {
	case .Init:
		pd.system.setUpdateCallback(dummyUpdate, nil)
		run_test_suites(pd, {PLATFORM_TESTS, ALLOCATOR_TESTS})
	}
	return 0
}

@(export)
dummyUpdate :: proc "c" (userdata: rawptr) -> i32 {
	return 0
}

package test

import playdate "../playdate"

@(export)
eventHandler :: proc "c" (pd: ^playdate.API, event: playdate.PD_System_Event, arg: i32) -> i32 {
	#partial switch event {
	case .Init:
		pd.system.setUpdateCallback(dummyUpdate, nil)
		playdate.init_default_context(pd)
		context = playdate.default_context()

		run_test_suites({PLATFORM_TESTS, ALLOCATOR_TESTS, LOGGER_TESTS, RANDOM_GENERATOR_TESTS})
	}
	return 0
}

@(export)
dummyUpdate :: proc "c" (userdata: rawptr) -> i32 {
	return 0
}

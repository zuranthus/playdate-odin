package main

import playdate "../playdate"
import "core:log"

@(export)
eventHandler :: proc "c" (pd: ^playdate.API, event: playdate.PD_System_Event, arg: i32) -> i32 {
	if event == .Init {
		pd.system.setUpdateCallback(updateCallback, nil)
		playdate.init_default_context(pd)
	}
	context = playdate.default_context()

	#partial switch event {
	case .Init:
		onInit()
		free_all(context.temp_allocator)
	}
	return 0
}

updateCallback :: proc "c" (ud: rawptr) -> i32 {
	context = playdate.default_context()
	defer free_all(context.temp_allocator)

	return onUpdate()
}

onInit :: proc() {
	log.info("onInit called")
}

onUpdate :: proc() -> i32 {
	log.info("onUpdate called")

	return 1
}

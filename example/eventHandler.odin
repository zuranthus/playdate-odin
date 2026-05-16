package main

import playdate "../playdate"

@(export)
eventHandler :: proc "c" (pd: ^playdate.API, event: playdate.PDSystemEvent, arg: i32) -> i32 {
	if event == .Init {
		pd.system.setUpdateCallback(onUpdate, pd)
		playdate.init_default_context(pd)
	}
	context = playdate.default_context()

	#partial switch event {
	case .Init:
		onInit(pd)
	}
	return 0
}

onInit :: proc(pd: ^playdate.API) {
	pd.system.logToConsole("onInit called")
}

onUpdate :: proc "c" (ud: rawptr) -> i32 {
	pd := cast(^playdate.API)ud
	context = playdate.default_context()

	pd.system.logToConsole("onUpdate called")
	return 1
}

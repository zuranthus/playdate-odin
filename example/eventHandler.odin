package main

import playdate "../playdate"

@(export)
eventHandler :: proc "c" (pd: ^playdate.API, event: playdate.PDSystemEvent, arg: i32) -> i32 {
	#partial switch event {
	case .Init:
		onInit(pd)
		pd.system.setUpdateCallback(onUpdate, pd)
	}
	return 0
}

onInit :: proc "c" (pd: ^playdate.API) {
	pd.system.logToConsole("onInit called")
}

onUpdate :: proc "c" (ud: rawptr) -> i32 {
	pd := cast(^playdate.API)ud
	pd.system.logToConsole("onUpdate called")
	return 1
}

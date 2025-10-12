//
//  pdext_sys.h
//  Playdate Simulator
//
//  Created by Dave Hayden on 10/6/17.
//  Copyright © 2017 Panic, Inc. All rights reserved.
//
package playdate





// pdext_sys_h :: 

PDButtons :: enum u32 {
	Left  = 1,
	Right = 2,
	Up    = 4,
	Down  = 8,
	B     = 16,
	A     = 32,
}

PDLanguage :: enum u32 {
	English,
	Japanese,
	Unknown,
}


accessReply :: enum u32 {
	Ask,
	Deny,
	Allow,
}

PDDateTime :: struct {
	year:    i32,
	month:   i32, // 1-12
	day:     i32, // 1-31
	weekday: i32, // 1=monday-7=sunday
	hour:    i32, // 0-23
	minute:  i32,
	second:  i32,
}

PDMenuItem :: struct {}

PDPeripherals :: enum u32 {
	None           = 0,
	Accelerometer  = 1,

	// ...
	AllPeripherals = 65535,
}

PDCallbackFunction :: proc "c" (rawptr) -> i32 // return 0 when done

PDMenuItemCallbackFunction :: proc "c" (rawptr)

PDButtonCallbackFunction :: proc "c" (PDButtons, i32, i32, rawptr) -> i32

PDInfo :: struct {
	osversion: i32,
	language:  PDLanguage,
}

sys :: struct {
	realloc:                    proc "c" (rawptr, i32) -> rawptr, // ptr = NULL -> malloc, size = 0 -> free
	formatString:               proc "c" ([^]cstring, cstring, #c_vararg ..any) -> i32,
	logToConsole:               proc "c" (cstring, #c_vararg ..any),
	error:                      proc "c" (cstring, #c_vararg ..any),
	getLanguage:                proc "c" () -> PDLanguage,
	getCurrentTimeMilliseconds: proc "c" () -> u32,
	getSecondsSinceEpoch:       proc "c" (^u32) -> u32,
	drawFPS:                    proc "c" (i32, i32),
	setUpdateCallback:          proc "c" (PDCallbackFunction, rawptr),
	getButtonState:             proc "c" (^PDButtons, ^PDButtons, ^PDButtons),
	setPeripheralsEnabled:      proc "c" (PDPeripherals),
	getAccelerometer:           proc "c" (^f32, ^f32, ^f32),
	getCrankChange:             proc "c" () -> f32,
	getCrankAngle:              proc "c" () -> f32,
	isCrankDocked:              proc "c" () -> i32,
	setCrankSoundsDisabled:     proc "c" (i32) -> i32,            // returns previous setting
	getFlipped:                 proc "c" () -> i32,
	setAutoLockDisabled:        proc "c" (i32),
	setMenuImage:               proc "c" (^i32, i32),
	addMenuItem:                proc "c" (cstring, PDMenuItemCallbackFunction, rawptr) -> ^PDMenuItem,
	addCheckmarkMenuItem:       proc "c" (cstring, i32, PDMenuItemCallbackFunction, rawptr) -> ^PDMenuItem,
	addOptionsMenuItem:         proc "c" (cstring, [^]cstring, i32, PDMenuItemCallbackFunction, rawptr) -> ^PDMenuItem,
	removeAllMenuItems:         proc "c" (),
	removeMenuItem:             proc "c" (^PDMenuItem),
	getMenuItemValue:           proc "c" (^PDMenuItem) -> i32,
	setMenuItemValue:           proc "c" (^PDMenuItem, i32),
	getMenuItemTitle:           proc "c" (^PDMenuItem) -> cstring,
	setMenuItemTitle:           proc "c" (^PDMenuItem, cstring),
	getMenuItemUserdata:        proc "c" (^PDMenuItem) -> rawptr,
	setMenuItemUserdata:        proc "c" (^PDMenuItem, rawptr),
	getReduceFlashing:          proc "c" () -> i32,

	// 1.1
	getElapsedTime: proc "c" () -> f32,
	resetElapsedTime:           proc "c" (),

	// 1.4
	getBatteryPercentage: proc "c" () -> f32,
	getBatteryVoltage:          proc "c" () -> f32,

	// 1.13
	int32_t: proc "c" (^i32) -> proc "c" () -> i32,
	shouldDisplay24HourTime:    proc "c" () -> i32,
	convertEpochToDateTime:     proc "c" (i32, ^PDDateTime),
	uint32_t:                   proc "c" (^i32) -> proc "c" (^PDDateTime) -> i32,

	// 2.0
	clearICache: proc "c" (),

	// 2.4
	setButtonCallback: proc "c" (PDButtonCallbackFunction, rawptr, i32),
	setSerialMessageCallback:   proc "c" (proc "c" (cstring)),
	vaFormatString:             proc "c" ([^]cstring, cstring, i32) -> i32,
	parseString:                proc "c" (cstring, cstring, #c_vararg ..any) -> i32,

	// ???
	delay: proc "c" (i32),

	// 2.7
	getServerTime: proc "c" (proc "c" (cstring, cstring)),
	restartGame:                proc "c" (cstring),
	getLaunchArgs:              proc "c" ([^]cstring) -> cstring,
	bool:                       proc "c" (^i32) -> proc "c" (i32, rawptr, i32) -> i32,

	// 3.0
	getSystemInfo: proc "c" () -> ^PDInfo,
}


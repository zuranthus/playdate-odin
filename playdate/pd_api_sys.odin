//
//  pdext_sys.h
//  Playdate Simulator
//
//  Created by Dave Hayden on 10/6/17.
//  Copyright © 2017 Panic, Inc. All rights reserved.
//
package playdate

import "core:c"

PDButton :: enum u32 {
	Left  = 0,
	Right = 1,
	Up    = 2,
	Down  = 3,
	B     = 4,
	A     = 5,
}

PDButtons :: bit_set[PDButton; i32]

PDLanguage :: enum u32 {
	English  = 0,
	Japanese = 1,
	Unknown  = 2,
}


accessReply :: enum u32 {
	Ask   = 0,
	Deny  = 1,
	Allow = 2,
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

PDCallbackFunction         :: proc "c" (userdata: rawptr) -> i32 // return 0 when done
PDMenuItemCallbackFunction :: proc "c" (userdata: rawptr)
PDButtonCallbackFunction   :: proc "c" (button: PDButtons, down: i32, _when: i32, userdata: rawptr) -> i32

PDInfo :: struct {
	osversion: i32,
	language:  PDLanguage,
}

sys :: struct {
	realloc:                    proc "c" (ptr: rawptr, size: i32) -> rawptr, // ptr = NULL -> malloc, size = 0 -> free
	formatString:               proc "c" (ret: ^cstring, fmt: cstring, #c_vararg _: ..any) -> i32,
	logToConsole:               proc "c" (fmt: cstring, #c_vararg _: ..any),
	error:                      proc "c" (fmt: cstring, #c_vararg _: ..any),
	getLanguage:                proc "c" () -> PDLanguage,
	getCurrentTimeMilliseconds: proc "c" () -> u32,
	getSecondsSinceEpoch:       proc "c" (milliseconds: ^u32) -> u32,
	drawFPS:                    proc "c" (x: i32, y: i32),
	setUpdateCallback:          proc "c" (update: PDCallbackFunction, userdata: rawptr),
	getButtonState:             proc "c" (current: ^PDButtons, pushed: ^PDButtons, released: ^PDButtons),
	setPeripheralsEnabled:      proc "c" (mask: PDPeripherals),
	getAccelerometer:           proc "c" (outx: ^f32, outy: ^f32, outz: ^f32),
	getCrankChange:             proc "c" () -> f32,
	getCrankAngle:              proc "c" () -> f32,
	isCrankDocked:              proc "c" () -> i32,
	setCrankSoundsDisabled:     proc "c" (flag: i32) -> i32,                 // returns previous setting
	getFlipped:                 proc "c" () -> i32,
	setAutoLockDisabled:        proc "c" (disable: i32),
	setMenuImage:               proc "c" (bitmap: ^i32, xOffset: i32),
	addMenuItem:                proc "c" (title: cstring, callback: PDMenuItemCallbackFunction, userdata: rawptr) -> ^PDMenuItem,
	addCheckmarkMenuItem:       proc "c" (title: cstring, value: i32, callback: PDMenuItemCallbackFunction, userdata: rawptr) -> ^PDMenuItem,
	addOptionsMenuItem:         proc "c" (title: cstring, optionTitles: ^cstring, optionsCount: i32, f: PDMenuItemCallbackFunction, userdata: rawptr) -> ^PDMenuItem,
	removeAllMenuItems:         proc "c" (),
	removeMenuItem:             proc "c" (menuItem: ^PDMenuItem),
	getMenuItemValue:           proc "c" (menuItem: ^PDMenuItem) -> i32,
	setMenuItemValue:           proc "c" (menuItem: ^PDMenuItem, value: i32),
	getMenuItemTitle:           proc "c" (menuItem: ^PDMenuItem) -> cstring,
	setMenuItemTitle:           proc "c" (menuItem: ^PDMenuItem, title: cstring),
	getMenuItemUserdata:        proc "c" (menuItem: ^PDMenuItem) -> rawptr,
	setMenuItemUserdata:        proc "c" (menuItem: ^PDMenuItem, ud: rawptr),
	getReduceFlashing:          proc "c" () -> i32,

	// 1.1
	getElapsedTime:   proc "c" () -> f32,
	resetElapsedTime: proc "c" (),

	// 1.4
	getBatteryPercentage: proc "c" () -> f32,
	getBatteryVoltage:    proc "c" () -> f32,

	// 1.13
	int32_t:                 proc "c" (getTimezoneOffset: ^i32) -> proc "c" () -> i32,
	shouldDisplay24HourTime: proc "c" () -> i32,
	convertEpochToDateTime:  proc "c" (epoch: i32, datetime: ^PDDateTime),
	uint32_t:                proc "c" (datetime: ^PDDateTime, convertDateTimeToEpoch: ^i32) -> proc "c" (^PDDateTime) -> i32,

	// 2.0
	clearICache: proc "c" (),

	// 2.4
	setButtonCallback:        proc "c" (cb: PDButtonCallbackFunction, buttonud: rawptr, queuesize: i32),
	setSerialMessageCallback: proc "c" (callback: proc "c" (data: cstring)),
	vaFormatString:           proc "c" (outstr: ^cstring, fmt: cstring, args: c.va_list) -> i32,
	parseString:              proc "c" (str: cstring, format: cstring, #c_vararg _: ..any) -> i32,

	// ???
	delay: proc "c" (milliseconds: i32),

	// 2.7
	getServerTime:  proc "c" (callback: proc "c" (time: cstring, err: cstring)),
	restartGame:    proc "c" (launchargs: cstring),
	getLaunchArgs:  proc "c" (outpath: ^cstring) -> cstring,
	sendMirrorData: proc "c" (command: i32, data: rawptr, len: i32) -> bool,

	// 3.0
	getSystemInfo: proc "c" () -> ^PDInfo,
}


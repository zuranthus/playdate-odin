//
//  pd_api.h
//  Playdate C API
//
//  Created by Dave Hayden on 7/30/14.
//  Copyright (c) 2014 Panic, Inc. All rights reserved.
//
package playdate

import "core:c"

SDFile :: struct {}

FileOption :: enum u32 {
	Read     = 0,
	ReadData = 1,
	Write    = 2,
	Append   = 3,
}

FileOptions :: bit_set[FileOption; i32]

FileStat :: struct {
	isdir:    i32,
	size:     u32,
	m_year:   i32,
	m_month:  i32,
	m_day:    i32,
	m_hour:   i32,
	m_minute: i32,
	m_second: i32,
}

SEEK_SET        :: 0       /* Seek from beginning of file.  */
SEEK_CUR        :: 1       /* Seek from current position.  */
SEEK_END        :: 2       /* Set file pointer to EOF plus "offset" */

file :: struct {
	geterr:    proc "c" () -> cstring,
	listfiles: proc "c" (path: cstring, callback: proc "c" (path: cstring, userdata: rawptr), userdata: rawptr, showhidden: i32) -> i32,
	stat:      proc "c" (path: cstring, stat: ^FileStat) -> i32,
	mkdir:     proc "c" (path: cstring) -> i32,
	unlink:    proc "c" (name: cstring, recursive: i32) -> i32,
	rename:    proc "c" (from: cstring, to: cstring) -> i32,
	open:      proc "c" (name: cstring, mode: FileOptions) -> ^SDFile,
	close:     proc "c" (file: ^SDFile) -> i32,
	read:      proc "c" (file: ^SDFile, buf: rawptr, len: u32) -> i32,
	write:     proc "c" (file: ^SDFile, buf: rawptr, len: u32) -> i32,
	flush:     proc "c" (file: ^SDFile) -> i32,
	tell:      proc "c" (file: ^SDFile) -> i32,
	seek:      proc "c" (file: ^SDFile, pos: i32, whence: i32) -> i32,
}

LCDRect :: struct {
	left:   i32,
	right:  i32, // not inclusive
	top:    i32,
	bottom: i32, // not inclusive
}

LCD_COLUMNS :: 400
LCD_ROWS    :: 240
LCD_ROWSIZE :: 52

LCDBitmapDrawMode :: enum u32 {
	Copy             = 0,
	WhiteTransparent = 1,
	BlackTransparent = 2,
	FillWhite        = 3,
	FillBlack        = 4,
	XOR              = 5,
	NXOR             = 6,
	Inverted         = 7,
}

LCDBitmapFlip :: enum u32 {
	Unflipped = 0,
	FlippedX  = 1,
	FlippedY  = 2,
	FlippedXY = 3,
}

LCDSolidColor :: enum u32 {
	Black = 0,
	White = 1,
	Clear = 2,
	XOR   = 3,
}

LCDLineCapStyle :: enum u32 {
	Butt   = 0,
	Square = 1,
	Round  = 2,
}

LCDFontLanguage :: enum u32 {
	English  = 0,
	Japanese = 1,
	Unknown  = 2,
}

PDStringEncoding :: enum u32 {
	ASCIIEncoding    = 0,
	UTF8Encoding     = 1,
	_16BitLEEncoding = 2,
}

LCDPattern :: [16]u8      // 8x8 pattern: 8 rows image data, 8 rows mask
LCDColor   :: c.uintptr_t // LCDSolidColor or pointer to LCDPattern

LCDPolygonFillRule :: enum u32 {
	NonZero = 0,
	EvenOdd = 1,
}

PDTextWrappingMode :: enum u32 {
	Clip      = 0,
	Character = 1,
	Word      = 2,
}

PDTextAlignment :: enum u32 {
	Left   = 0,
	Center = 1,
	Right  = 2,
}

LCDBitmap       :: struct {}
LCDBitmapTable  :: struct {}
LCDFont         :: struct {}
LCDFontData     :: struct {}
LCDFontPage     :: struct {}
LCDFontGlyph    :: struct {}
LCDTileMap      :: struct {}
LCDVideoPlayer  :: struct {}
LCDStreamPlayer :: struct {}
HTTPConnection  :: struct {}
TCPConnection   :: struct {}
FilePlayer      :: struct {}

video :: struct {
	loadVideo:        proc "c" (path: cstring) -> ^LCDVideoPlayer,
	freePlayer:       proc "c" (p: ^LCDVideoPlayer),
	setContext:       proc "c" (p: ^LCDVideoPlayer, _context: ^LCDBitmap) -> i32,
	useScreenContext: proc "c" (p: ^LCDVideoPlayer),
	renderFrame:      proc "c" (p: ^LCDVideoPlayer, n: i32) -> i32,
	getError:         proc "c" (p: ^LCDVideoPlayer) -> cstring,
	getInfo:          proc "c" (p: ^LCDVideoPlayer, outWidth: ^i32, outHeight: ^i32, outFrameRate: ^f32, outFrameCount: ^i32, outCurrentFrame: ^i32),
	getContext:       proc "c" (p: ^LCDVideoPlayer) -> ^LCDBitmap,
}

videostream :: struct {
	newPlayer:         proc "c" () -> ^LCDStreamPlayer,
	freePlayer:        proc "c" (p: ^LCDStreamPlayer),
	setBufferSize:     proc "c" (p: ^LCDStreamPlayer, video: i32, audio: i32),
	setFile:           proc "c" (p: ^LCDStreamPlayer, file: ^SDFile),
	setHTTPConnection: proc "c" (p: ^LCDStreamPlayer, conn: ^HTTPConnection),
	getFilePlayer:     proc "c" (p: ^LCDStreamPlayer) -> ^FilePlayer,
	getVideoPlayer:    proc "c" (p: ^LCDStreamPlayer) -> ^LCDVideoPlayer,

	//	int (*setContext)(LCDStreamPlayer* p, LCDBitmap* context);
	//	LCDBitmap* (*getContext)(LCDStreamPlayer* p);
	
	// returns true if it drew a frame, else false
	update:                proc "c" (p: ^LCDStreamPlayer) -> bool,
	getBufferedFrameCount: proc "c" (p: ^LCDStreamPlayer) -> i32,
	getBytesRead:          proc "c" (p: ^LCDStreamPlayer) -> u32,

	// 3.0
	setTCPConnection: proc "c" (p: ^LCDStreamPlayer, conn: ^TCPConnection),
}

tilemap :: struct {
	newTilemap:        proc "c" () -> ^LCDTileMap,
	freeTilemap:       proc "c" (m: ^LCDTileMap),
	setImageTable:     proc "c" (m: ^LCDTileMap, table: ^LCDBitmapTable),
	getImageTable:     proc "c" (m: ^LCDTileMap) -> ^LCDBitmapTable,
	setSize:           proc "c" (m: ^LCDTileMap, tilesWide: i32, tilesHigh: i32),
	getSize:           proc "c" (m: ^LCDTileMap, tilesWide: ^i32, tilesHigh: ^i32),
	getPixelSize:      proc "c" (m: ^LCDTileMap, outWidth: ^u32, outHeight: ^u32),
	setTiles:          proc "c" (m: ^LCDTileMap, indexes: ^u16, count: i32, rowwidth: i32),
	setTileAtPosition: proc "c" (m: ^LCDTileMap, x: i32, y: i32, idx: u16),
	getTileAtPosition: proc "c" (m: ^LCDTileMap, x: i32, y: i32) -> i32,
	drawAtPoint:       proc "c" (m: ^LCDTileMap, x: f32, y: f32),
}

graphics :: struct {
	video: ^video,

	// Drawing Functions
	clear:              proc "c" (color: LCDColor),
	setBackgroundColor: proc "c" (color: LCDSolidColor),
	setStencil:         proc "c" (stencil: ^LCDBitmap), // deprecated in favor of setStencilImage, which adds a "tile" flag
	setDrawMode:        proc "c" (mode: LCDBitmapDrawMode) -> LCDBitmapDrawMode,
	setDrawOffset:      proc "c" (dx: i32, dy: i32),
	setClipRect:        proc "c" (x: i32, y: i32, width: i32, height: i32),
	clearClipRect:      proc "c" (),
	setLineCapStyle:    proc "c" (endCapStyle: LCDLineCapStyle),
	setFont:            proc "c" (font: ^LCDFont),
	setTextTracking:    proc "c" (tracking: i32),
	pushContext:        proc "c" (target: ^LCDBitmap),
	popContext:         proc "c" (),
	drawBitmap:         proc "c" (bitmap: ^LCDBitmap, x: i32, y: i32, flip: LCDBitmapFlip),
	tileBitmap:         proc "c" (bitmap: ^LCDBitmap, x: i32, y: i32, width: i32, height: i32, flip: LCDBitmapFlip),
	drawLine:           proc "c" (x1: i32, y1: i32, x2: i32, y2: i32, width: i32, color: LCDColor),
	fillTriangle:       proc "c" (x1: i32, y1: i32, x2: i32, y2: i32, x3: i32, y3: i32, color: LCDColor),
	drawRect:           proc "c" (x: i32, y: i32, width: i32, height: i32, color: LCDColor),
	fillRect:           proc "c" (x: i32, y: i32, width: i32, height: i32, color: LCDColor),
	drawEllipse:        proc "c" (x: i32, y: i32, width: i32, height: i32, lineWidth: i32, startAngle: f32, endAngle: f32, color: LCDColor), // stroked inside the rect
	fillEllipse:        proc "c" (x: i32, y: i32, width: i32, height: i32, startAngle: f32, endAngle: f32, color: LCDColor),
	drawScaledBitmap:   proc "c" (bitmap: ^LCDBitmap, x: i32, y: i32, xscale: f32, yscale: f32),
	drawText:           proc "c" (text: rawptr, len: c.size_t, encoding: PDStringEncoding, x: i32, y: i32) -> i32,

	// LCDBitmap
	newBitmap:      proc "c" (width: i32, height: i32, bgcolor: LCDColor) -> ^LCDBitmap,
	freeBitmap:     proc "c" (^LCDBitmap),
	loadBitmap:     proc "c" (path: cstring, outerr: ^cstring) -> ^LCDBitmap,
	copyBitmap:     proc "c" (bitmap: ^LCDBitmap) -> ^LCDBitmap,
	loadIntoBitmap: proc "c" (path: cstring, bitmap: ^LCDBitmap, outerr: ^cstring),
	getBitmapData:  proc "c" (bitmap: ^LCDBitmap, width: ^i32, height: ^i32, rowbytes: ^i32, mask: ^^u8, data: ^^u8),
	clearBitmap:    proc "c" (bitmap: ^LCDBitmap, bgcolor: LCDColor),
	rotatedBitmap:  proc "c" (bitmap: ^LCDBitmap, rotation: f32, xscale: f32, yscale: f32, allocedSize: ^i32) -> ^LCDBitmap,

	// LCDBitmapTable
	newBitmapTable:      proc "c" (count: i32, width: i32, height: i32) -> ^LCDBitmapTable,
	freeBitmapTable:     proc "c" (table: ^LCDBitmapTable),
	loadBitmapTable:     proc "c" (path: cstring, outerr: ^cstring) -> ^LCDBitmapTable,
	loadIntoBitmapTable: proc "c" (path: cstring, table: ^LCDBitmapTable, outerr: ^cstring),
	getTableBitmap:      proc "c" (table: ^LCDBitmapTable, idx: i32) -> ^LCDBitmap,

	// LCDFont
	loadFont:        proc "c" (path: cstring, outErr: ^cstring) -> ^LCDFont,
	getFontPage:     proc "c" (font: ^LCDFont, _c: u32) -> ^LCDFontPage,
	getPageGlyph:    proc "c" (page: ^LCDFontPage, _c: u32, bitmap: ^^LCDBitmap, advance: ^i32) -> ^LCDFontGlyph,
	getGlyphKerning: proc "c" (glyph: ^LCDFontGlyph, glyphcode: u32, nextcode: u32) -> i32,
	getTextWidth:    proc "c" (font: ^LCDFont, text: rawptr, len: c.size_t, encoding: PDStringEncoding, tracking: i32) -> i32,

	// raw framebuffer access
	getFrame:              proc "c" () -> ^u8,        // row stride = LCD_ROWSIZE
	getDisplayFrame:       proc "c" () -> ^u8,        // row stride = LCD_ROWSIZE
	getDebugBitmap:        proc "c" () -> ^LCDBitmap, // valid in simulator only, function is NULL on device
	copyFrameBufferBitmap: proc "c" () -> ^LCDBitmap,
	markUpdatedRows:       proc "c" (start: i32, end: i32),
	display:               proc "c" (),

	// misc util.
	setColorToPattern:  proc "c" (color: ^LCDColor, bitmap: ^LCDBitmap, x: i32, y: i32),
	checkMaskCollision: proc "c" (bitmap1: ^LCDBitmap, x1: i32, y1: i32, flip1: LCDBitmapFlip, bitmap2: ^LCDBitmap, x2: i32, y2: i32, flip2: LCDBitmapFlip, rect: LCDRect) -> i32,

	// 1.1
	setScreenClipRect: proc "c" (x: i32, y: i32, width: i32, height: i32),

	// 1.1.1
	fillPolygon:   proc "c" (nPoints: i32, coords: ^i32, color: LCDColor, fillrule: LCDPolygonFillRule),
	getFontHeight: proc "c" (font: ^LCDFont) -> u8,

	// 1.7
	getDisplayBufferBitmap: proc "c" () -> ^LCDBitmap,
	drawRotatedBitmap:      proc "c" (bitmap: ^LCDBitmap, x: i32, y: i32, rotation: f32, centerx: f32, centery: f32, xscale: f32, yscale: f32),
	setTextLeading:         proc "c" (lineHeightAdustment: i32),

	// 1.8
	setBitmapMask: proc "c" (bitmap: ^LCDBitmap, mask: ^LCDBitmap) -> i32,
	getBitmapMask: proc "c" (bitmap: ^LCDBitmap) -> ^LCDBitmap,

	// 1.10
	setStencilImage: proc "c" (stencil: ^LCDBitmap, tile: i32),

	// 1.12
	makeFontFromData: proc "c" (data: ^LCDFontData, wide: i32) -> ^LCDFont,

	// 2.1
	getTextTracking: proc "c" () -> i32,

	// 2.5
	setPixel:           proc "c" (x: i32, y: i32, _c: LCDColor),
	getBitmapPixel:     proc "c" (bitmap: ^LCDBitmap, x: i32, y: i32) -> LCDSolidColor,
	getBitmapTableInfo: proc "c" (table: ^LCDBitmapTable, count: ^i32, width: ^i32),

	// 2.6
	drawTextInRect: proc "c" (text: rawptr, len: c.size_t, encoding: PDStringEncoding, x: i32, y: i32, width: i32, height: i32, wrap: PDTextWrappingMode, align: PDTextAlignment),

	// 2.7
	getTextHeightForMaxWidth: proc "c" (font: ^LCDFont, text: rawptr, len: c.size_t, maxwidth: i32, encoding: PDStringEncoding, wrap: PDTextWrappingMode, tracking: i32, extraLeading: i32) -> i32,
	drawRoundRect:            proc "c" (x: i32, y: i32, width: i32, height: i32, radius: i32, lineWidth: i32, color: LCDColor),
	fillRoundRect:            proc "c" (x: i32, y: i32, width: i32, height: i32, radius: i32, color: LCDColor),

	// 3.0
	tilemap:     ^tilemap,
	videostream: ^videostream,
}

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

AccessRequestCallback :: proc "c" (allowed: bool, userdata: rawptr)

accessReply :: enum u32 {
	Ask   = 0,
	Deny  = 1,
	Allow = 2,
}

PDDateTime :: struct {
	year:    u16,
	month:   u8, // 1-12
	day:     u8, // 1-31
	weekday: u8, // 1=monday-7=sunday
	hour:    u8, // 0-23
	minute:  u8,
	second:  u8,
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
PDButtonCallbackFunction   :: proc "c" (button: PDButtons, down: i32, _when: u32, userdata: rawptr) -> i32

PDInfo :: struct {
	osversion: u32,
	language:  PDLanguage,
}

sys :: struct {
	realloc:                    proc "c" (ptr: rawptr, size: c.size_t) -> rawptr, // ptr = NULL -> malloc, size = 0 -> free
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
	setCrankSoundsDisabled:     proc "c" (flag: i32) -> i32,                      // returns previous setting
	getFlipped:                 proc "c" () -> i32,
	setAutoLockDisabled:        proc "c" (disable: i32),
	setMenuImage:               proc "c" (bitmap: ^LCDBitmap, xOffset: i32),
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
	getTimezoneOffset:       proc "c" () -> i32,
	shouldDisplay24HourTime: proc "c" () -> i32,
	convertEpochToDateTime:  proc "c" (epoch: u32, datetime: ^PDDateTime),
	convertDateTimeToEpoch:  proc "c" (datetime: ^PDDateTime) -> u32,

	// 2.0
	clearICache: proc "c" (),

	// 2.4
	setButtonCallback:        proc "c" (cb: PDButtonCallbackFunction, buttonud: rawptr, queuesize: i32),
	setSerialMessageCallback: proc "c" (callback: proc "c" (data: cstring)),
	vaFormatString:           proc "c" (outstr: ^cstring, fmt: cstring, args: c.va_list) -> i32,
	parseString:              proc "c" (str: cstring, format: cstring, #c_vararg _: ..any) -> i32,

	// ???
	delay: proc "c" (milliseconds: u32),

	// 2.7
	getServerTime:  proc "c" (callback: proc "c" (time: cstring, err: cstring)),
	restartGame:    proc "c" (launchargs: cstring),
	getLaunchArgs:  proc "c" (outpath: ^cstring) -> cstring,
	sendMirrorData: proc "c" (command: u8, data: rawptr, len: i32) -> bool,

	// 3.0
	getSystemInfo: proc "c" () -> ^PDInfo,
}

lua_State     :: rawptr
lua_CFunction :: proc "c" (L: ^lua_State) -> i32
LuaUDObject   :: struct {}
LCDSprite     :: struct {}

l_valtype :: enum u32 {
	Int   = 0,
	Float = 1,
	Str   = 2,
}

lua_reg :: struct {
	name: cstring,
	func: lua_CFunction,
}

LuaType :: enum u32 {
	Nil      = 0,
	Bool     = 1,
	Int      = 2,
	Float    = 3,
	String   = 4,
	Table    = 5,
	Function = 6,
	Thread   = 7,
	Object   = 8,
}

lua_val :: struct {
	name: cstring,
	type: l_valtype,

	v: struct #raw_union {
		intval:   u32,
		floatval: f32,
		strval:   cstring,
	},
}

lua :: struct {
	// these two return 1 on success, else 0 with an error message in outErr
	addFunction:    proc "c" (f: lua_CFunction, name: cstring, outErr: ^cstring) -> i32,
	registerClass:  proc "c" (name: cstring, reg: ^lua_reg, vals: ^lua_val, isstatic: i32, outErr: ^cstring) -> i32,
	pushFunction:   proc "c" (f: lua_CFunction),
	indexMetatable: proc "c" () -> i32,
	stop:           proc "c" (),
	start:          proc "c" (),

	// stack operations
	getArgCount:  proc "c" () -> i32,
	getArgType:   proc "c" (pos: i32, outClass: ^cstring) -> LuaType,
	argIsNil:     proc "c" (pos: i32) -> i32,
	getArgBool:   proc "c" (pos: i32) -> i32,
	getArgInt:    proc "c" (pos: i32) -> i32,
	getArgFloat:  proc "c" (pos: i32) -> f32,
	getArgString: proc "c" (pos: i32) -> cstring,
	getArgBytes:  proc "c" (pos: i32, outlen: ^c.size_t) -> cstring,
	getArgObject: proc "c" (pos: i32, type: cstring, outud: ^^LuaUDObject) -> rawptr,
	getBitmap:    proc "c" (pos: i32) -> ^LCDBitmap,
	getSprite:    proc "c" (pos: i32) -> ^LCDSprite,

	// for returning values back to Lua
	pushNil:       proc "c" (),
	pushBool:      proc "c" (val: i32),
	pushInt:       proc "c" (val: i32),
	pushFloat:     proc "c" (val: f32),
	pushString:    proc "c" (str: cstring),
	pushBytes:     proc "c" (str: cstring, len: c.size_t),
	pushBitmap:    proc "c" (bitmap: ^LCDBitmap),
	pushSprite:    proc "c" (sprite: ^LCDSprite),
	pushObject:    proc "c" (obj: rawptr, type: cstring, nValues: i32) -> ^LuaUDObject,
	retainObject:  proc "c" (obj: ^LuaUDObject) -> ^LuaUDObject,
	releaseObject: proc "c" (obj: ^LuaUDObject),
	setUserValue:  proc "c" (obj: ^LuaUDObject, slot: u32),        // sets item on top of stack and pops it
	getUserValue:  proc "c" (obj: ^LuaUDObject, slot: u32) -> i32, // pushes item at slot to top of stack, returns stack position

	// calling lua from C has some overhead. use sparingly!
	callFunction_deprecated: proc "c" (name: cstring, nargs: i32),
	callFunction:            proc "c" (name: cstring, nargs: i32, outerr: ^cstring) -> i32,
}

json_value_type :: enum u32 {
	Null    = 0,
	True    = 1,
	False   = 2,
	Integer = 3,
	Float   = 4,
	String  = 5,
	Array   = 6,
	Table   = 7,
}

json_value :: struct {
	type: i8,

	data: struct #raw_union {
		intval:    i32,
		floatval:  f32,
		stringval: cstring,
		arrayval:  rawptr,
		tableval:  rawptr,
	},
}

json_decoder :: struct {
	decodeError: proc "c" (decoder: ^json_decoder, error: cstring, linenum: i32),

	// the following functions are each optional
	willDecodeSublist:             proc "c" (decoder: ^json_decoder, name: cstring, type: json_value_type),
	shouldDecodeTableValueForKey:  proc "c" (decoder: ^json_decoder, key: cstring) -> i32,
	didDecodeTableValue:           proc "c" (decoder: ^json_decoder, key: cstring, value: json_value),
	shouldDecodeArrayValueAtIndex: proc "c" (decoder: ^json_decoder, pos: i32) -> i32,
	didDecodeArrayValue:           proc "c" (decoder: ^json_decoder, pos: i32, value: json_value), // if pos==0, this was a bare value at the root of the file
	didDecodeSublist:              proc "c" (decoder: ^json_decoder, name: cstring, type: json_value_type) -> rawptr,
	userdata:                      rawptr,
	returnString:                  i32,                                                            // when set, the decoder skips parsing and returns the current subtree as a string
	path:                          cstring,                                                        // updated during parsing, reflects current position in tree
}

// fill buffer, return bytes written or -1 on end of data
json_readFunc :: proc "c" (userdata: rawptr, buf: ^u8, bufsize: i32) -> i32

json_reader :: struct {
	read:     json_readFunc,
	userdata: rawptr, // passed back to the read function above
}

// encoder
json_writeFunc :: proc "c" (userdata: rawptr, str: cstring, len: i32)

json_encoder :: struct {
	writeStringFunc: json_writeFunc,
	userdata:        rawptr,
	pretty:          i32,
	startedTable:    i32,
	startedArray:    i32,
	depth:           i32,
	startArray:      proc "c" (encoder: ^json_encoder),
	addArrayMember:  proc "c" (encoder: ^json_encoder),
	endArray:        proc "c" (encoder: ^json_encoder),
	startTable:      proc "c" (encoder: ^json_encoder),
	addTableMember:  proc "c" (encoder: ^json_encoder, name: cstring, len: i32),
	endTable:        proc "c" (encoder: ^json_encoder),
	writeNull:       proc "c" (encoder: ^json_encoder),
	writeFalse:      proc "c" (encoder: ^json_encoder),
	writeTrue:       proc "c" (encoder: ^json_encoder),
	writeInt:        proc "c" (encoder: ^json_encoder, num: i32),
	writeDouble:     proc "c" (encoder: ^json_encoder, num: f64),
	writeString:     proc "c" (encoder: ^json_encoder, str: cstring, len: i32),
}

json :: struct {
	initEncoder:  proc "c" (encoder: ^json_encoder, write: json_writeFunc, userdata: rawptr, pretty: i32),
	decode:       proc "c" (functions: ^json_decoder, reader: json_reader, outval: ^json_value) -> i32,
	decodeString: proc "c" (functions: ^json_decoder, jsonString: cstring, outval: ^json_value) -> i32,
}

SpriteCollisionResponseType :: enum u32 {
	Slide   = 0,
	Freeze  = 1,
	Overlap = 2,
	Bounce  = 3,
}

PDRect :: struct {
	x:      f32,
	y:      f32,
	width:  f32,
	height: f32,
}

CollisionPoint :: struct {
	x: f32,
	y: f32,
}

CollisionVector :: struct {
	x: i32,
	y: i32,
}

SpriteCollisionInfo :: struct {
	sprite:       ^LCDSprite,                  // The sprite being moved
	other:        ^LCDSprite,                  // The sprite colliding with the sprite being moved
	responseType: SpriteCollisionResponseType, // The result of collisionResponse
	overlaps:     u8,                          // True if the sprite was overlapping other when the collision started. False if it didn’t overlap but tunneled through other.
	ti:           f32,                         // A number between 0 and 1 indicating how far along the movement to the goal the collision occurred
	move:         CollisionPoint,              // The difference between the original coordinates and the actual ones when the collision happened
	normal:       CollisionVector,             // The collision normal; usually -1, 0, or 1 in x and y. Use this value to determine things like if your character is touching the ground.
	touch:        CollisionPoint,              // The coordinates where the sprite started touching other
	spriteRect:   PDRect,                      // The rectangle the sprite occupied when the touch happened
	otherRect:    PDRect,                      // The rectangle the sprite being collided with occupied when the touch happened
}

SpriteQueryInfo :: struct {
	sprite: ^LCDSprite, // The sprite being intersected by the segment

	// ti1 and ti2 are numbers between 0 and 1 which indicate how far from the starting point of the line segment the collision happened
	ti1:        f32,            // entry point
	ti2:        f32,            // exit point
	entryPoint: CollisionPoint, // The coordinates of the first intersection between sprite and the line segment
	exitPoint:  CollisionPoint, // The coordinates of the second intersection between sprite and the line segment
}

CWCollisionInfo              :: struct {}
CWItemInfo                   :: struct {}
LCDSpriteDrawFunction        :: proc "c" (sprite: ^LCDSprite, bounds: PDRect, drawrect: PDRect)
LCDSpriteUpdateFunction      :: proc "c" (sprite: ^LCDSprite)
LCDSpriteCollisionFilterProc :: proc "c" (sprite: ^LCDSprite, other: ^LCDSprite) -> SpriteCollisionResponseType

sprite :: struct {
	setAlwaysRedraw:       proc "c" (flag: i32),
	addDirtyRect:          proc "c" (dirtyRect: LCDRect),
	drawSprites:           proc "c" (),
	updateAndDrawSprites:  proc "c" (),
	newSprite:             proc "c" () -> ^LCDSprite,
	freeSprite:            proc "c" (sprite: ^LCDSprite),
	copy:                  proc "c" (sprite: ^LCDSprite) -> ^LCDSprite,
	addSprite:             proc "c" (sprite: ^LCDSprite),
	removeSprite:          proc "c" (sprite: ^LCDSprite),
	removeSprites:         proc "c" (sprites: ^^LCDSprite, count: i32),
	removeAllSprites:      proc "c" (),
	getSpriteCount:        proc "c" () -> i32,
	setBounds:             proc "c" (sprite: ^LCDSprite, bounds: PDRect),
	getBounds:             proc "c" (sprite: ^LCDSprite) -> PDRect,
	moveTo:                proc "c" (sprite: ^LCDSprite, x: f32, y: f32),
	moveBy:                proc "c" (sprite: ^LCDSprite, dx: f32, dy: f32),
	setImage:              proc "c" (sprite: ^LCDSprite, image: ^LCDBitmap, flip: LCDBitmapFlip),
	getImage:              proc "c" (sprite: ^LCDSprite) -> ^LCDBitmap,
	setSize:               proc "c" (s: ^LCDSprite, width: f32, height: f32),
	setZIndex:             proc "c" (sprite: ^LCDSprite, zIndex: i16),
	getZIndex:             proc "c" (sprite: ^LCDSprite) -> i16,
	setDrawMode:           proc "c" (sprite: ^LCDSprite, mode: LCDBitmapDrawMode),
	setImageFlip:          proc "c" (sprite: ^LCDSprite, flip: LCDBitmapFlip),
	getImageFlip:          proc "c" (sprite: ^LCDSprite) -> LCDBitmapFlip,
	setStencil:            proc "c" (sprite: ^LCDSprite, stencil: ^LCDBitmap), // deprecated in favor of setStencilImage()
	setClipRect:           proc "c" (sprite: ^LCDSprite, clipRect: LCDRect),
	clearClipRect:         proc "c" (sprite: ^LCDSprite),
	setClipRectsInRange:   proc "c" (clipRect: LCDRect, startZ: i32, endZ: i32),
	clearClipRectsInRange: proc "c" (startZ: i32, endZ: i32),
	setUpdatesEnabled:     proc "c" (sprite: ^LCDSprite, flag: i32),
	updatesEnabled:        proc "c" (sprite: ^LCDSprite) -> i32,
	setCollisionsEnabled:  proc "c" (sprite: ^LCDSprite, flag: i32),
	collisionsEnabled:     proc "c" (sprite: ^LCDSprite) -> i32,
	setVisible:            proc "c" (sprite: ^LCDSprite, flag: i32),
	isVisible:             proc "c" (sprite: ^LCDSprite) -> i32,
	setOpaque:             proc "c" (sprite: ^LCDSprite, flag: i32),
	markDirty:             proc "c" (sprite: ^LCDSprite),
	setTag:                proc "c" (sprite: ^LCDSprite, tag: u8),
	getTag:                proc "c" (sprite: ^LCDSprite) -> u8,
	setIgnoresDrawOffset:  proc "c" (sprite: ^LCDSprite, flag: i32),
	setUpdateFunction:     proc "c" (sprite: ^LCDSprite, func: LCDSpriteUpdateFunction),
	setDrawFunction:       proc "c" (sprite: ^LCDSprite, func: LCDSpriteDrawFunction),
	getPosition:           proc "c" (sprite: ^LCDSprite, x: ^f32, y: ^f32),

	// Collisions
	resetCollisionWorld: proc "c" (),
	setCollideRect:      proc "c" (sprite: ^LCDSprite, collideRect: PDRect),
	getCollideRect:      proc "c" (sprite: ^LCDSprite) -> PDRect,
	clearCollideRect:    proc "c" (sprite: ^LCDSprite),

	// caller is responsible for freeing the returned array for all collision methods
	setCollisionResponseFunction: proc "c" (sprite: ^LCDSprite, func: LCDSpriteCollisionFilterProc),
	checkCollisions:              proc "c" (sprite: ^LCDSprite, goalX: f32, goalY: f32, actualX: ^f32, actualY: ^f32, len: ^i32) -> ^SpriteCollisionInfo, // access results using SpriteCollisionInfo *info = &results[i];
	moveWithCollisions:           proc "c" (sprite: ^LCDSprite, goalX: f32, goalY: f32, actualX: ^f32, actualY: ^f32, len: ^i32) -> ^SpriteCollisionInfo,
	querySpritesAtPoint:          proc "c" (x: f32, y: f32, len: ^i32) -> ^^LCDSprite,
	querySpritesInRect:           proc "c" (x: f32, y: f32, width: f32, height: f32, len: ^i32) -> ^^LCDSprite,
	querySpritesAlongLine:        proc "c" (x1: f32, y1: f32, x2: f32, y2: f32, len: ^i32) -> ^^LCDSprite,
	querySpriteInfoAlongLine:     proc "c" (x1: f32, y1: f32, x2: f32, y2: f32, len: ^i32) -> ^SpriteQueryInfo, // access results using SpriteQueryInfo *info = &results[i];
	overlappingSprites:           proc "c" (sprite: ^LCDSprite, len: ^i32) -> ^^LCDSprite,
	allOverlappingSprites:        proc "c" (len: ^i32) -> ^^LCDSprite,

	// added in 1.7
	setStencilPattern: proc "c" (sprite: ^LCDSprite, pattern: ^[8]u8),
	clearStencil:      proc "c" (sprite: ^LCDSprite),
	setUserdata:       proc "c" (sprite: ^LCDSprite, userdata: rawptr),
	getUserdata:       proc "c" (sprite: ^LCDSprite) -> rawptr,

	// added in 1.10
	setStencilImage: proc "c" (sprite: ^LCDSprite, stencil: ^LCDBitmap, tile: i32),

	// 2.1
	setCenter: proc "c" (s: ^LCDSprite, x: f32, y: f32),
	getCenter: proc "c" (s: ^LCDSprite, x: ^f32, y: ^f32),

	// 2.7
	setTilemap: proc "c" (s: ^LCDSprite, tilemap: ^LCDTileMap),
	getTilemap: proc "c" (s: ^LCDSprite) -> ^LCDTileMap,
}

AUDIO_FRAMES_PER_CYCLE :: 512

SoundFormat :: enum u32 {
	_8bitMono    = 0,
	_8bitStereo  = 1,
	_16bitMono   = 2,
	_16bitStereo = 3,
	ADPCMMono    = 4,
	ADPCMStereo  = 5,
}

MIDINote :: f32

NOTE_C4 :: 60

SoundSource     :: struct {}
sndCallbackProc :: proc "c" (_c: ^SoundSource, userdata: rawptr)

// SoundSource is the parent class for FilePlayer, SamplePlayer, PDSynth, and DelayLineTap. You can safely cast those objects to a SoundSource* and use these functions:
sound_source :: struct {
	setVolume:         proc "c" (_c: ^SoundSource, lvol: f32, rvol: f32),
	getVolume:         proc "c" (_c: ^SoundSource, outl: ^f32, outr: ^f32),
	isPlaying:         proc "c" (_c: ^SoundSource) -> i32,
	setFinishCallback: proc "c" (_c: ^SoundSource, callback: sndCallbackProc, userdata: rawptr),
}

sound_fileplayer :: struct {
	newPlayer:          proc "c" () -> ^FilePlayer,
	freePlayer:         proc "c" (player: ^FilePlayer),
	loadIntoPlayer:     proc "c" (player: ^FilePlayer, path: cstring) -> i32,
	setBufferLength:    proc "c" (player: ^FilePlayer, bufferLen: f32),
	play:               proc "c" (player: ^FilePlayer, repeat: i32) -> i32,
	isPlaying:          proc "c" (player: ^FilePlayer) -> i32,
	pause:              proc "c" (player: ^FilePlayer),
	stop:               proc "c" (player: ^FilePlayer),
	setVolume:          proc "c" (player: ^FilePlayer, left: f32, right: f32),
	getVolume:          proc "c" (player: ^FilePlayer, left: ^f32, right: ^f32),
	getLength:          proc "c" (player: ^FilePlayer) -> f32,
	setOffset:          proc "c" (player: ^FilePlayer, offset: f32),
	setRate:            proc "c" (player: ^FilePlayer, rate: f32),
	setLoopRange:       proc "c" (player: ^FilePlayer, start: f32, end: f32),
	didUnderrun:        proc "c" (player: ^FilePlayer) -> i32,
	setFinishCallback:  proc "c" (player: ^FilePlayer, callback: sndCallbackProc, userdata: rawptr),
	setLoopCallback:    proc "c" (player: ^FilePlayer, callback: sndCallbackProc, userdata: rawptr),
	getOffset:          proc "c" (player: ^FilePlayer) -> f32,
	getRate:            proc "c" (player: ^FilePlayer) -> f32,
	setStopOnUnderrun:  proc "c" (player: ^FilePlayer, flag: i32),
	fadeVolume:         proc "c" (player: ^FilePlayer, left: f32, right: f32, len: i32, finishCallback: sndCallbackProc, userdata: rawptr),
	setMP3StreamSource: proc "c" (player: ^FilePlayer, dataSource: proc "c" (data: ^u8, bytes: i32, userdata: rawptr) -> i32, userdata: rawptr, bufferLen: f32),
}

AudioSample  :: struct {}
SamplePlayer :: struct {}

sound_sample :: struct {
	newSampleBuffer:   proc "c" (byteCount: i32) -> ^AudioSample,
	loadIntoSample:    proc "c" (sample: ^AudioSample, path: cstring) -> i32,
	load:              proc "c" (path: cstring) -> ^AudioSample,
	newSampleFromData: proc "c" (data: ^u8, format: SoundFormat, sampleRate: u32, byteCount: i32, shouldFreeData: i32) -> ^AudioSample,
	getData:           proc "c" (sample: ^AudioSample, data: ^^u8, format: ^SoundFormat, sampleRate: ^u32, bytelength: ^u32),
	freeSample:        proc "c" (sample: ^AudioSample),
	getLength:         proc "c" (sample: ^AudioSample) -> f32,

	// 2.4
	decompress: proc "c" (sample: ^AudioSample) -> i32,
}

sound_sampleplayer :: struct {
	newPlayer:         proc "c" () -> ^SamplePlayer,
	freePlayer:        proc "c" (player: ^SamplePlayer),
	setSample:         proc "c" (player: ^SamplePlayer, sample: ^AudioSample),
	play:              proc "c" (player: ^SamplePlayer, repeat: i32, rate: f32) -> i32,
	isPlaying:         proc "c" (player: ^SamplePlayer) -> i32,
	stop:              proc "c" (player: ^SamplePlayer),
	setVolume:         proc "c" (player: ^SamplePlayer, left: f32, right: f32),
	getVolume:         proc "c" (player: ^SamplePlayer, left: ^f32, right: ^f32),
	getLength:         proc "c" (player: ^SamplePlayer) -> f32,
	setOffset:         proc "c" (player: ^SamplePlayer, offset: f32),
	setRate:           proc "c" (player: ^SamplePlayer, rate: f32),
	setPlayRange:      proc "c" (player: ^SamplePlayer, start: i32, end: i32),
	setFinishCallback: proc "c" (player: ^SamplePlayer, callback: sndCallbackProc, userdata: rawptr),
	setLoopCallback:   proc "c" (player: ^SamplePlayer, callback: sndCallbackProc, userdata: rawptr),
	getOffset:         proc "c" (player: ^SamplePlayer) -> f32,
	getRate:           proc "c" (player: ^SamplePlayer) -> f32,
	setPaused:         proc "c" (player: ^SamplePlayer, flag: i32),
} // SamplePlayer extends SoundSource

PDSynthSignalValue :: struct {}
PDSynthSignal      :: struct {}
signalStepFunc     :: proc "c" (userdata: rawptr, ioframes: ^i32, ifval: ^f32) -> f32
signalNoteOnFunc   :: proc "c" (userdata: rawptr, note: MIDINote, vel: f32, len: f32) // len = -1 for indefinite
signalNoteOffFunc  :: proc "c" (userdata: rawptr, stopped: i32, offset: i32)          // stopped = 0 on note release, = 1 when note actually stops playing; offset is # of frames into the current cycle
signalDeallocFunc  :: proc "c" (userdata: rawptr)

sound_signal :: struct {
	newSignal:      proc "c" (step: signalStepFunc, noteOn: signalNoteOnFunc, noteOff: signalNoteOffFunc, dealloc: signalDeallocFunc, userdata: rawptr) -> ^PDSynthSignal,
	freeSignal:     proc "c" (signal: ^PDSynthSignal),
	getValue:       proc "c" (signal: ^PDSynthSignal) -> f32,
	setValueScale:  proc "c" (signal: ^PDSynthSignal, scale: f32),
	setValueOffset: proc "c" (signal: ^PDSynthSignal, offset: f32),

	// 2.6
	newSignalForValue: proc "c" (value: ^PDSynthSignalValue) -> ^PDSynthSignal,
}

LFOType :: enum u32 {
	Square        = 0,
	Triangle      = 1,
	Sine          = 2,
	SampleAndHold = 3,
	SawtoothUp    = 4,
	SawtoothDown  = 5,
	Arpeggiator   = 6,
	Function      = 7,
}

PDSynthLFO :: struct {} // inherits from SynthSignal

sound_lfo :: struct {
	newLFO:          proc "c" (type: LFOType) -> ^PDSynthLFO,
	freeLFO:         proc "c" (lfo: ^PDSynthLFO),
	setType:         proc "c" (lfo: ^PDSynthLFO, type: LFOType),
	setRate:         proc "c" (lfo: ^PDSynthLFO, rate: f32),
	setPhase:        proc "c" (lfo: ^PDSynthLFO, phase: f32),
	setCenter:       proc "c" (lfo: ^PDSynthLFO, center: f32),
	setDepth:        proc "c" (lfo: ^PDSynthLFO, depth: f32),
	setArpeggiation: proc "c" (lfo: ^PDSynthLFO, nSteps: i32, steps: ^f32),
	setFunction:     proc "c" (lfo: ^PDSynthLFO, lfoFunc: proc "c" (lfo: ^PDSynthLFO, userdata: rawptr) -> f32, userdata: rawptr, interpolate: i32),
	setDelay:        proc "c" (lfo: ^PDSynthLFO, holdoff: f32, ramptime: f32),
	setRetrigger:    proc "c" (lfo: ^PDSynthLFO, flag: i32),
	getValue:        proc "c" (lfo: ^PDSynthLFO) -> f32,

	// 1.10
	setGlobal: proc "c" (lfo: ^PDSynthLFO, global: i32),

	// 2.2
	setStartPhase: proc "c" (lfo: ^PDSynthLFO, phase: f32),
}

PDSynthEnvelope :: struct {} // inherits from SynthSignal

sound_envelope :: struct {
	newEnvelope:  proc "c" (attack: f32, decay: f32, sustain: f32, release: f32) -> ^PDSynthEnvelope,
	freeEnvelope: proc "c" (env: ^PDSynthEnvelope),
	setAttack:    proc "c" (env: ^PDSynthEnvelope, attack: f32),
	setDecay:     proc "c" (env: ^PDSynthEnvelope, decay: f32),
	setSustain:   proc "c" (env: ^PDSynthEnvelope, sustain: f32),
	setRelease:   proc "c" (env: ^PDSynthEnvelope, release: f32),
	setLegato:    proc "c" (env: ^PDSynthEnvelope, flag: i32),
	setRetrigger: proc "c" (lfo: ^PDSynthEnvelope, flag: i32),
	getValue:     proc "c" (env: ^PDSynthEnvelope) -> f32,

	// 1.13
	setCurvature:           proc "c" (env: ^PDSynthEnvelope, amount: f32),
	setVelocitySensitivity: proc "c" (env: ^PDSynthEnvelope, velsens: f32),
	setRateScaling:         proc "c" (env: ^PDSynthEnvelope, scaling: f32, start: MIDINote, end: MIDINote),
}

SoundWaveform :: enum u32 {
	Square    = 0,
	Triangle  = 1,
	Sine      = 2,
	Noise     = 3,
	Sawtooth  = 4,
	POPhase   = 5,
	PODigital = 6,
	POVosim   = 7,
}

// generator render callback
// samples are in Q8.24 format. left is either the left channel or the single mono channel,
// right is non-NULL only if the stereo flag was set in the setGenerator() call.
// nsamples is at most 256 but may be shorter
// rate is Q0.32 per-frame phase step, drate is per-frame rate step (i.e., do rate += drate every frame)
// return value is the number of sample frames rendered
synthRenderFunc :: proc "c" (userdata: rawptr, left: ^i32, right: ^i32, nsamples: i32, rate: u32, drate: i32) -> i32

// generator event callbacks
synthNoteOnFunc       :: proc "c" (userdata: rawptr, note: MIDINote, velocity: f32, len: f32) // len == -1 if indefinite
synthReleaseFunc      :: proc "c" (userdata: rawptr, stop: i32)
synthSetParameterFunc :: proc "c" (userdata: rawptr, parameter: i32, value: f32) -> i32
synthDeallocFunc      :: proc "c" (userdata: rawptr)
synthCopyUserdata     :: proc "c" (userdata: rawptr) -> rawptr
PDSynth               :: struct {}

sound_synth :: struct {
	newSynth:                proc "c" () -> ^PDSynth,
	freeSynth:               proc "c" (synth: ^PDSynth),
	setWaveform:             proc "c" (synth: ^PDSynth, wave: SoundWaveform),
	setGenerator_deprecated: proc "c" (synth: ^PDSynth, stereo: i32, render: synthRenderFunc, noteOn: synthNoteOnFunc, release: synthReleaseFunc, setparam: synthSetParameterFunc, dealloc: synthDeallocFunc, userdata: rawptr),
	setSample:               proc "c" (synth: ^PDSynth, sample: ^AudioSample, sustainStart: u32, sustainEnd: u32),
	setAttackTime:           proc "c" (synth: ^PDSynth, attack: f32),
	setDecayTime:            proc "c" (synth: ^PDSynth, decay: f32),
	setSustainLevel:         proc "c" (synth: ^PDSynth, sustain: f32),
	setReleaseTime:          proc "c" (synth: ^PDSynth, release: f32),
	setTranspose:            proc "c" (synth: ^PDSynth, halfSteps: f32),
	setFrequencyModulator:   proc "c" (synth: ^PDSynth, mod: ^PDSynthSignalValue),
	getFrequencyModulator:   proc "c" (synth: ^PDSynth) -> ^PDSynthSignalValue,
	setAmplitudeModulator:   proc "c" (synth: ^PDSynth, mod: ^PDSynthSignalValue),
	getAmplitudeModulator:   proc "c" (synth: ^PDSynth) -> ^PDSynthSignalValue,
	getParameterCount:       proc "c" (synth: ^PDSynth) -> i32,
	setParameter:            proc "c" (synth: ^PDSynth, parameter: i32, value: f32) -> i32,
	setParameterModulator:   proc "c" (synth: ^PDSynth, parameter: i32, mod: ^PDSynthSignalValue),
	getParameterModulator:   proc "c" (synth: ^PDSynth, parameter: i32) -> ^PDSynthSignalValue,
	playNote:                proc "c" (synth: ^PDSynth, freq: f32, vel: f32, len: f32, _when: u32),      // len == -1 for indefinite
	playMIDINote:            proc "c" (synth: ^PDSynth, note: MIDINote, vel: f32, len: f32, _when: u32), // len == -1 for indefinite
	noteOff:                 proc "c" (synth: ^PDSynth, _when: u32),                                     // move to release part of envelope
	stop:                    proc "c" (synth: ^PDSynth),                                                 // stop immediately
	setVolume:               proc "c" (synth: ^PDSynth, left: f32, right: f32),
	getVolume:               proc "c" (synth: ^PDSynth, left: ^f32, right: ^f32),
	isPlaying:               proc "c" (synth: ^PDSynth) -> i32,

	// 1.13
	getEnvelope: proc "c" (synth: ^PDSynth) -> ^PDSynthEnvelope, // synth keeps ownership--don't free this!

	// 2.2
	setWavetable: proc "c" (synth: ^PDSynth, sample: ^AudioSample, log2size: i32, columns: i32, rows: i32) -> i32,

	// 2.4
	setGenerator: proc "c" (synth: ^PDSynth, stereo: i32, render: synthRenderFunc, noteOn: synthNoteOnFunc, release: synthReleaseFunc, setparam: synthSetParameterFunc, dealloc: synthDeallocFunc, copyUserdata: synthCopyUserdata, userdata: rawptr),
	copy:         proc "c" (synth: ^PDSynth) -> ^PDSynth,

	// 2.6
	clearEnvelope: proc "c" (synth: ^PDSynth),
} // PDSynth extends SoundSource

ControlSignal :: struct {}

control_signal :: struct {
	newSignal:               proc "c" () -> ^ControlSignal,
	freeSignal:              proc "c" (signal: ^ControlSignal),
	clearEvents:             proc "c" (control: ^ControlSignal),
	addEvent:                proc "c" (control: ^ControlSignal, step: i32, value: f32, interpolate: i32),
	removeEvent:             proc "c" (control: ^ControlSignal, step: i32),
	getMIDIControllerNumber: proc "c" (control: ^ControlSignal) -> i32,
}

PDSynthInstrument :: struct {}

sound_instrument :: struct {
	newInstrument:     proc "c" () -> ^PDSynthInstrument,
	freeInstrument:    proc "c" (inst: ^PDSynthInstrument),
	addVoice:          proc "c" (inst: ^PDSynthInstrument, synth: ^PDSynth, rangeStart: MIDINote, rangeEnd: MIDINote, transpose: f32) -> i32,
	playNote:          proc "c" (inst: ^PDSynthInstrument, frequency: f32, vel: f32, len: f32, _when: u32) -> ^PDSynth,
	playMIDINote:      proc "c" (inst: ^PDSynthInstrument, note: MIDINote, vel: f32, len: f32, _when: u32) -> ^PDSynth,
	setPitchBend:      proc "c" (inst: ^PDSynthInstrument, bend: f32),
	setPitchBendRange: proc "c" (inst: ^PDSynthInstrument, halfSteps: f32),
	setTranspose:      proc "c" (inst: ^PDSynthInstrument, halfSteps: f32),
	noteOff:           proc "c" (inst: ^PDSynthInstrument, note: MIDINote, _when: u32),
	allNotesOff:       proc "c" (inst: ^PDSynthInstrument, _when: u32),
	setVolume:         proc "c" (inst: ^PDSynthInstrument, left: f32, right: f32),
	getVolume:         proc "c" (inst: ^PDSynthInstrument, left: ^f32, right: ^f32),
	activeVoiceCount:  proc "c" (inst: ^PDSynthInstrument) -> i32,
}

SequenceTrack :: struct {}

sound_track :: struct {
	newTrack:              proc "c" () -> ^SequenceTrack,
	freeTrack:             proc "c" (track: ^SequenceTrack),
	setInstrument:         proc "c" (track: ^SequenceTrack, inst: ^PDSynthInstrument),
	getInstrument:         proc "c" (track: ^SequenceTrack) -> ^PDSynthInstrument,
	addNoteEvent:          proc "c" (track: ^SequenceTrack, step: u32, len: u32, note: MIDINote, velocity: f32),
	removeNoteEvent:       proc "c" (track: ^SequenceTrack, step: u32, note: MIDINote),
	clearNotes:            proc "c" (track: ^SequenceTrack),
	getControlSignalCount: proc "c" (track: ^SequenceTrack) -> i32,
	getControlSignal:      proc "c" (track: ^SequenceTrack, idx: i32) -> ^ControlSignal,
	clearControlEvents:    proc "c" (track: ^SequenceTrack),
	getPolyphony:          proc "c" (track: ^SequenceTrack) -> i32,
	activeVoiceCount:      proc "c" (track: ^SequenceTrack) -> i32,
	setMuted:              proc "c" (track: ^SequenceTrack, mute: i32),

	// 1.1
	getLength:       proc "c" (track: ^SequenceTrack) -> u32, // in steps, includes full last note
	getIndexForStep: proc "c" (track: ^SequenceTrack, step: u32) -> i32,
	getNoteAtIndex:  proc "c" (track: ^SequenceTrack, index: i32, outStep: ^u32, outLen: ^u32, outNote: ^MIDINote, outVelocity: ^f32) -> i32,

	// 1.10
	getSignalForController: proc "c" (track: ^SequenceTrack, controller: i32, create: i32) -> ^ControlSignal,
}

SoundSequence            :: struct {}
SequenceFinishedCallback :: proc "c" (seq: ^SoundSequence, userdata: rawptr)

sound_sequence :: struct {
	newSequence:         proc "c" () -> ^SoundSequence,
	freeSequence:        proc "c" (sequence: ^SoundSequence),
	loadMIDIFile:        proc "c" (seq: ^SoundSequence, path: cstring) -> i32,
	getTime:             proc "c" (seq: ^SoundSequence) -> u32,
	setTime:             proc "c" (seq: ^SoundSequence, time: u32),
	setLoops:            proc "c" (seq: ^SoundSequence, loopstart: i32, loopend: i32, loops: i32),
	getTempo_deprecated: proc "c" (seq: ^SoundSequence) -> i32,
	setTempo:            proc "c" (seq: ^SoundSequence, stepsPerSecond: f32),
	getTrackCount:       proc "c" (seq: ^SoundSequence) -> i32,
	addTrack:            proc "c" (seq: ^SoundSequence) -> ^SequenceTrack,
	getTrackAtIndex:     proc "c" (seq: ^SoundSequence, track: u32) -> ^SequenceTrack,
	setTrackAtIndex:     proc "c" (seq: ^SoundSequence, track: ^SequenceTrack, idx: u32),
	allNotesOff:         proc "c" (seq: ^SoundSequence),

	// 1.1
	isPlaying:      proc "c" (seq: ^SoundSequence) -> i32,
	getLength:      proc "c" (seq: ^SoundSequence) -> u32, // in steps, includes full last note
	play:           proc "c" (seq: ^SoundSequence, finishCallback: SequenceFinishedCallback, userdata: rawptr),
	stop:           proc "c" (seq: ^SoundSequence),
	getCurrentStep: proc "c" (seq: ^SoundSequence, timeOffset: ^i32) -> i32,
	setCurrentStep: proc "c" (seq: ^SoundSequence, step: i32, timeOffset: i32, playNotes: i32),

	// 2.5
	getTempo: proc "c" (seq: ^SoundSequence) -> f32,
}

TwoPoleFilter :: struct {}

TwoPoleFilterType :: enum u32 {
	LowPass   = 0,
	HighPass  = 1,
	BandPass  = 2,
	Notch     = 3,
	PEQ       = 4,
	LowShelf  = 5,
	HighShelf = 6,
}

sound_effect_twopolefilter :: struct {
	newFilter:             proc "c" () -> ^TwoPoleFilter,
	freeFilter:            proc "c" (filter: ^TwoPoleFilter),
	setType:               proc "c" (filter: ^TwoPoleFilter, type: TwoPoleFilterType),
	setFrequency:          proc "c" (filter: ^TwoPoleFilter, frequency: f32),
	setFrequencyModulator: proc "c" (filter: ^TwoPoleFilter, signal: ^PDSynthSignalValue),
	getFrequencyModulator: proc "c" (filter: ^TwoPoleFilter) -> ^PDSynthSignalValue,
	setGain:               proc "c" (filter: ^TwoPoleFilter, gain: f32),
	setResonance:          proc "c" (filter: ^TwoPoleFilter, resonance: f32),
	setResonanceModulator: proc "c" (filter: ^TwoPoleFilter, signal: ^PDSynthSignalValue),
	getResonanceModulator: proc "c" (filter: ^TwoPoleFilter) -> ^PDSynthSignalValue,
}

OnePoleFilter :: struct {}

sound_effect_onepolefilter :: struct {
	newFilter:             proc "c" () -> ^OnePoleFilter,
	freeFilter:            proc "c" (filter: ^OnePoleFilter),
	setParameter:          proc "c" (filter: ^OnePoleFilter, parameter: f32),
	setParameterModulator: proc "c" (filter: ^OnePoleFilter, signal: ^PDSynthSignalValue),
	getParameterModulator: proc "c" (filter: ^OnePoleFilter) -> ^PDSynthSignalValue,
}

BitCrusher :: struct {}

sound_effect_bitcrusher :: struct {
	newBitCrusher:           proc "c" () -> ^BitCrusher,
	freeBitCrusher:          proc "c" (filter: ^BitCrusher),
	setAmount:               proc "c" (filter: ^BitCrusher, amount: f32),
	setAmountModulator:      proc "c" (filter: ^BitCrusher, signal: ^PDSynthSignalValue),
	getAmountModulator:      proc "c" (filter: ^BitCrusher) -> ^PDSynthSignalValue,
	setUndersampling:        proc "c" (filter: ^BitCrusher, undersampling: f32),
	setUndersampleModulator: proc "c" (filter: ^BitCrusher, signal: ^PDSynthSignalValue),
	getUndersampleModulator: proc "c" (filter: ^BitCrusher) -> ^PDSynthSignalValue,
}

RingModulator :: struct {}

sound_effect_ringmodulator :: struct {
	newRingmod:            proc "c" () -> ^RingModulator,
	freeRingmod:           proc "c" (filter: ^RingModulator),
	setFrequency:          proc "c" (filter: ^RingModulator, frequency: f32),
	setFrequencyModulator: proc "c" (filter: ^RingModulator, signal: ^PDSynthSignalValue),
	getFrequencyModulator: proc "c" (filter: ^RingModulator) -> ^PDSynthSignalValue,
}

DelayLine    :: struct {}
DelayLineTap :: struct {}

sound_effect_delayline :: struct {
	newDelayLine:  proc "c" (length: i32, stereo: i32) -> ^DelayLine,
	freeDelayLine: proc "c" (filter: ^DelayLine),
	setLength:     proc "c" (d: ^DelayLine, frames: i32),
	setFeedback:   proc "c" (d: ^DelayLine, fb: f32),
	addTap:        proc "c" (d: ^DelayLine, delay: i32) -> ^DelayLineTap,

	// note that DelayLineTap is a SoundSource, not a SoundEffect
	freeTap:               proc "c" (tap: ^DelayLineTap),
	setTapDelay:           proc "c" (t: ^DelayLineTap, frames: i32),
	setTapDelayModulator:  proc "c" (t: ^DelayLineTap, mod: ^PDSynthSignalValue),
	getTapDelayModulator:  proc "c" (t: ^DelayLineTap) -> ^PDSynthSignalValue,
	setTapChannelsFlipped: proc "c" (t: ^DelayLineTap, flip: i32),
}

Overdrive :: struct {}

sound_effect_overdrive :: struct {
	newOverdrive:       proc "c" () -> ^Overdrive,
	freeOverdrive:      proc "c" (filter: ^Overdrive),
	setGain:            proc "c" (o: ^Overdrive, gain: f32),
	setLimit:           proc "c" (o: ^Overdrive, limit: f32),
	setLimitModulator:  proc "c" (o: ^Overdrive, mod: ^PDSynthSignalValue),
	getLimitModulator:  proc "c" (o: ^Overdrive) -> ^PDSynthSignalValue,
	setOffset:          proc "c" (o: ^Overdrive, offset: f32),
	setOffsetModulator: proc "c" (o: ^Overdrive, mod: ^PDSynthSignalValue),
	getOffsetModulator: proc "c" (o: ^Overdrive) -> ^PDSynthSignalValue,
}

SoundEffect :: struct {}
effectProc  :: proc "c" (e: ^SoundEffect, left: ^i32, right: ^i32, nsamples: i32, bufactive: i32) -> i32 // samples are in signed q8.24 format

sound_effect :: struct {
	newEffect:       proc "c" (_proc: effectProc, userdata: rawptr) -> ^SoundEffect,
	freeEffect:      proc "c" (effect: ^SoundEffect),
	setMix:          proc "c" (effect: ^SoundEffect, level: f32),
	setMixModulator: proc "c" (effect: ^SoundEffect, signal: ^PDSynthSignalValue),
	getMixModulator: proc "c" (effect: ^SoundEffect) -> ^PDSynthSignalValue,
	setUserdata:     proc "c" (effect: ^SoundEffect, userdata: rawptr),
	getUserdata:     proc "c" (effect: ^SoundEffect) -> rawptr,
	twopolefilter:   ^sound_effect_twopolefilter,
	onepolefilter:   ^sound_effect_onepolefilter,
	bitcrusher:      ^sound_effect_bitcrusher,
	ringmodulator:   ^sound_effect_ringmodulator,
	delayline:       ^sound_effect_delayline,
	overdrive:       ^sound_effect_overdrive,
}

SoundChannel        :: struct {}
AudioSourceFunction :: proc "c" (_context: rawptr, left: ^i16, right: ^i16, len: i32) -> i32 // len is # of samples in each buffer, function should return 1 if it produced output

sound_channel :: struct {
	newChannel:         proc "c" () -> ^SoundChannel,
	freeChannel:        proc "c" (channel: ^SoundChannel),
	addSource:          proc "c" (channel: ^SoundChannel, source: ^SoundSource) -> i32,
	removeSource:       proc "c" (channel: ^SoundChannel, source: ^SoundSource) -> i32,
	addCallbackSource:  proc "c" (channel: ^SoundChannel, callback: AudioSourceFunction, _context: rawptr, stereo: i32) -> ^SoundSource,
	addEffect:          proc "c" (channel: ^SoundChannel, effect: ^SoundEffect) -> i32,
	removeEffect:       proc "c" (channel: ^SoundChannel, effect: ^SoundEffect) -> i32,
	setVolume:          proc "c" (channel: ^SoundChannel, volume: f32),
	getVolume:          proc "c" (channel: ^SoundChannel) -> f32,
	setVolumeModulator: proc "c" (channel: ^SoundChannel, mod: ^PDSynthSignalValue),
	getVolumeModulator: proc "c" (channel: ^SoundChannel) -> ^PDSynthSignalValue,
	setPan:             proc "c" (channel: ^SoundChannel, pan: f32),
	setPanModulator:    proc "c" (channel: ^SoundChannel, mod: ^PDSynthSignalValue),
	getPanModulator:    proc "c" (channel: ^SoundChannel) -> ^PDSynthSignalValue,
	getDryLevelSignal:  proc "c" (channel: ^SoundChannel) -> ^PDSynthSignalValue,
	getWetLevelSignal:  proc "c" (channel: ^SoundChannel) -> ^PDSynthSignalValue,
}

RecordCallback :: proc "c" (_context: rawptr, buffer: ^i16, length: i32) -> i32 // data is mono

MicSource :: enum u32 {
	Autodetect = 0,
	Internal   = 1,
	Headset    = 2,
}

sound :: struct {
	channel:           ^sound_channel,
	fileplayer:        ^sound_fileplayer,
	sample:            ^sound_sample,
	sampleplayer:      ^sound_sampleplayer,
	synth:             ^sound_synth,
	sequence:          ^sound_sequence,
	effect:            ^sound_effect,
	lfo:               ^sound_lfo,
	envelope:          ^sound_envelope,
	source:            ^sound_source,
	controlsignal:     ^control_signal,
	track:             ^sound_track,
	instrument:        ^sound_instrument,
	getCurrentTime:    proc "c" () -> u32,
	addSource:         proc "c" (callback: AudioSourceFunction, _context: rawptr, stereo: i32) -> ^SoundSource,
	getDefaultChannel: proc "c" () -> ^SoundChannel,
	addChannel:        proc "c" (channel: ^SoundChannel) -> i32,
	removeChannel:     proc "c" (channel: ^SoundChannel) -> i32,
	setMicCallback:    proc "c" (callback: RecordCallback, _context: rawptr, source: MicSource) -> i32,
	getHeadphoneState: proc "c" (headphone: ^i32, headsetmic: ^i32, changeCallback: proc "c" (headphone: i32, mic: i32)),
	setOutputsActive:  proc "c" (headphone: i32, speaker: i32),

	// 1.5
	removeSource: proc "c" (source: ^SoundSource) -> i32,

	// 1.12
	signal: ^sound_signal,

	// 2.2
	getError: proc "c" () -> cstring,
}

display :: struct {
	getWidth:       proc "c" () -> i32,
	getHeight:      proc "c" () -> i32,
	setRefreshRate: proc "c" (rate: f32),
	setInverted:    proc "c" (flag: i32),
	setScale:       proc "c" (s: u32),
	setMosaic:      proc "c" (x: u32, y: u32),
	setFlipped:     proc "c" (x: i32, y: i32),
	setOffset:      proc "c" (x: i32, y: i32),

	// 2.7
	getRefreshRate: proc "c" () -> f32,
	getFPS:         proc "c" () -> f32,
}

PDScore :: struct {
	rank:   u32,
	value:  u32,
	player: cstring,
}

PDScoresList :: struct {
	boardID:        cstring,
	count:          u32,
	lastUpdated:    u32,
	playerIncluded: i32,
	limit:          u32,
	scores:         ^PDScore,
}

PDBoard :: struct {
	boardID: cstring,
	name:    cstring,
}

PDBoardsList :: struct {
	count:       u32,
	lastUpdated: u32,
	boards:      ^PDBoard,
}

AddScoreCallback     :: proc "c" (score: ^PDScore, errorMessage: cstring)
PersonalBestCallback :: proc "c" (score: ^PDScore, errorMessage: cstring)
BoardsListCallback   :: proc "c" (boards: ^PDBoardsList, errorMessage: cstring)
ScoresCallback       :: proc "c" (scores: ^PDScoresList, errorMessage: cstring)

scoreboards :: struct {
	addScore:        proc "c" (boardId: cstring, value: u32, callback: AddScoreCallback) -> i32,
	getPersonalBest: proc "c" (boardId: cstring, callback: PersonalBestCallback) -> i32,
	freeScore:       proc "c" (score: ^PDScore),
	getScoreboards:  proc "c" (callback: BoardsListCallback) -> i32,
	freeBoardsList:  proc "c" (boardsList: ^PDBoardsList),
	getScores:       proc "c" (boardId: cstring, callback: ScoresCallback) -> i32,
	freeScoresList:  proc "c" (scoresList: ^PDScoresList),
}

PDNetErr :: enum i32 {
	OK                  = 0,
	NO_DEVICE           = -1,
	BUSY                = -2,
	WRITE_ERROR         = -3,
	WRITE_BUSY          = -4,
	WRITE_TIMEOUT       = -5,
	READ_ERROR          = -6,
	READ_BUSY           = -7,
	READ_TIMEOUT        = -8,
	READ_OVERFLOW       = -9,
	FRAME_ERROR         = -10,
	BAD_RESPONSE        = -11,
	ERROR_RESPONSE      = -12,
	RESET_TIMEOUT       = -13,
	BUFFER_TOO_SMALL    = -14,
	UNEXPECTED_RESPONSE = -15,
	NOT_CONNECTED_TO_AP = -16,
	NOT_IMPLEMENTED     = -17,
	CONNECTION_CLOSED   = -18,
}

WifiStatus :: enum u32 {
	NotConnected = 0, //!< Not connected to an AP
	Connected    = 1, //!< Device is connected to an AP
	NotAvailable = 2, //!< A connection has been attempted and no configured AP was available
}

HTTPConnectionCallback :: proc "c" (connection: ^HTTPConnection)
HTTPHeaderCallback     :: proc "c" (conn: ^HTTPConnection, key: cstring, value: cstring)

http :: struct {
	requestAccess:               proc "c" (server: cstring, port: i32, usessl: bool, purpose: cstring, requestCallback: AccessRequestCallback, userdata: rawptr) -> accessReply,
	newConnection:               proc "c" (server: cstring, port: i32, usessl: bool) -> ^HTTPConnection,
	retain:                      proc "c" (http: ^HTTPConnection) -> ^HTTPConnection,
	release:                     proc "c" (http: ^HTTPConnection),
	setConnectTimeout:           proc "c" (connection: ^HTTPConnection, ms: i32),
	setKeepAlive:                proc "c" (connection: ^HTTPConnection, keepalive: bool),
	setByteRange:                proc "c" (connection: ^HTTPConnection, start: i32, end: i32),
	setUserdata:                 proc "c" (connection: ^HTTPConnection, userdata: rawptr),
	getUserdata:                 proc "c" (connection: ^HTTPConnection) -> rawptr,
	get:                         proc "c" (conn: ^HTTPConnection, path: cstring, headers: cstring, headerlen: c.size_t) -> PDNetErr,
	post:                        proc "c" (conn: ^HTTPConnection, path: cstring, headers: cstring, headerlen: c.size_t, body: cstring, bodylen: c.size_t) -> PDNetErr,
	query:                       proc "c" (conn: ^HTTPConnection, method: cstring, path: cstring, headers: cstring, headerlen: c.size_t, body: cstring, bodylen: c.size_t) -> PDNetErr,
	getError:                    proc "c" (connection: ^HTTPConnection) -> PDNetErr,
	getProgress:                 proc "c" (conn: ^HTTPConnection, read: ^i32, total: ^i32),
	getResponseStatus:           proc "c" (connection: ^HTTPConnection) -> i32,
	getBytesAvailable:           proc "c" (conn: ^HTTPConnection) -> c.size_t,
	setReadTimeout:              proc "c" (conn: ^HTTPConnection, ms: i32),
	setReadBufferSize:           proc "c" (conn: ^HTTPConnection, bytes: i32),
	read:                        proc "c" (conn: ^HTTPConnection, buf: rawptr, buflen: u32) -> i32,
	close:                       proc "c" (connection: ^HTTPConnection),
	setHeaderReceivedCallback:   proc "c" (connection: ^HTTPConnection, headercb: HTTPHeaderCallback),
	setHeadersReadCallback:      proc "c" (connection: ^HTTPConnection, callback: HTTPConnectionCallback),
	setResponseCallback:         proc "c" (connection: ^HTTPConnection, callback: HTTPConnectionCallback),
	setRequestCompleteCallback:  proc "c" (connection: ^HTTPConnection, callback: HTTPConnectionCallback),
	setConnectionClosedCallback: proc "c" (connection: ^HTTPConnection, callback: HTTPConnectionCallback),
}

TCPConnectionCallback :: proc "c" (connection: ^TCPConnection, err: PDNetErr)
TCPOpenCallback       :: proc "c" (conn: ^TCPConnection, err: PDNetErr, ud: rawptr)

tcp :: struct {
	requestAccess:               proc "c" (server: cstring, port: i32, usessl: bool, purpose: cstring, requestCallback: AccessRequestCallback, userdata: rawptr) -> accessReply,
	newConnection:               proc "c" (server: cstring, port: i32, usessl: bool) -> ^TCPConnection,
	retain:                      proc "c" (http: ^TCPConnection) -> ^TCPConnection,
	release:                     proc "c" (http: ^TCPConnection),
	getError:                    proc "c" (connection: ^TCPConnection) -> PDNetErr,
	setConnectTimeout:           proc "c" (connection: ^TCPConnection, ms: i32),
	setUserdata:                 proc "c" (connection: ^TCPConnection, userdata: rawptr),
	getUserdata:                 proc "c" (connection: ^TCPConnection) -> rawptr,
	open:                        proc "c" (conn: ^TCPConnection, cb: TCPOpenCallback, ud: rawptr) -> PDNetErr,
	close:                       proc "c" (conn: ^TCPConnection) -> PDNetErr,
	setConnectionClosedCallback: proc "c" (conn: ^TCPConnection, callback: TCPConnectionCallback),
	setReadTimeout:              proc "c" (conn: ^TCPConnection, ms: i32),
	setReadBufferSize:           proc "c" (conn: ^TCPConnection, bytes: i32),
	getBytesAvailable:           proc "c" (conn: ^TCPConnection) -> c.size_t,
	read:                        proc "c" (conn: ^TCPConnection, buffer: rawptr, length: c.size_t) -> i32, // returns # of bytes read, or PDNetErr on error
	write:                       proc "c" (conn: ^TCPConnection, buffer: rawptr, length: c.size_t) -> i32, // returns # of bytes sent, or PDNetErr on error
}

network :: struct {
	http:       ^http,
	tcp:        ^tcp,
	getStatus:  proc "c" () -> WifiStatus,
	setEnabled: proc "c" (flag: bool, callback: proc "c" (err: PDNetErr)),
	reserved:   [3]c.uintptr_t,
}

API :: struct {
	system:      ^sys,
	file:        ^file,
	graphics:    ^graphics,
	sprite:      ^sprite,
	display:     ^display,
	sound:       ^sound,
	lua:         ^lua,
	json:        ^json,
	scoreboards: ^scoreboards,
	network:     ^network,
}

PDSystemEvent :: enum u32 {
	Init          = 0,
	InitLua       = 1,
	Lock          = 2,
	Unlock        = 3,
	Pause         = 4,
	Resume        = 5,
	Terminate     = 6,
	KeyPressed    = 7, // arg is keycode
	KeyReleased   = 8,
	LowPower      = 9,
	MirrorStarted = 10,
	MirrorEnded   = 11,
}


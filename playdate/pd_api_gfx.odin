//
//  pdext_gfx.h
//  Playdate Simulator
//
//  Created by Dave Hayden on 10/6/17.
//  Copyright © 2017 Panic, Inc. All rights reserved.
//
package playdate





// pdext_gfx_h :: 

LCDRect :: struct {
	left:   i32,
	right:  i32, // not inclusive
	top:    i32,
	bottom: i32, // not inclusive
}

LCD_COLUMNS :: 400
LCD_ROWS :: 240
LCD_ROWSIZE :: 52
// LCD_SCREEN_RECT :: LCDMakeRect(0, 0, LCD_COLUMNS, LCD_ROWS)

LCDBitmapDrawMode :: enum u32 {
	Copy,
	WhiteTransparent,
	BlackTransparent,
	FillWhite,
	FillBlack,
	XOR,
	NXOR,
	Inverted,
}

LCDBitmapFlip :: enum u32 {
	Unflipped,
	FlippedX,
	FlippedY,
	FlippedXY,
}

LCDSolidColor :: enum u32 {
	Black,
	White,
	Clear,
	XOR,
}

LCDLineCapStyle :: enum u32 {
	Butt,
	Square,
	Round,
}

LCDFontLanguage :: enum u32 {
	English,
	Japanese,
	Unknown,
}

PDStringEncoding :: enum u32 {
	ASCIIEncoding,
	UTF8Encoding,
	_16BitLEEncoding,
}

LCDPattern :: [16]i32 // 8x8 pattern: 8 rows image data, 8 rows mask

LCDColor :: i32 // LCDSolidColor or pointer to LCDPattern

LCDPolygonFillRule :: enum u32 {
	NonZero,
	EvenOdd,
}

PDTextWrappingMode :: enum u32 {
	Clip,
	Character,
	Word,
}

PDTextAlignment :: enum u32 {
	Left,
	Center,
	Right,
}

LCDBitmap :: struct {}

LCDBitmapTable :: struct {}

LCDFont :: struct {}

LCDFontData :: struct {}

LCDFontPage :: struct {}

LCDFontGlyph :: struct {}

LCDTileMap :: struct {}

LCDVideoPlayer :: struct {}

LCDStreamPlayer :: struct {}




video :: struct {
	loadVideo:        proc "c" (cstring) -> ^LCDVideoPlayer,
	freePlayer:       proc "c" (^LCDVideoPlayer),
	setContext:       proc "c" (^LCDVideoPlayer, ^LCDBitmap) -> i32,
	useScreenContext: proc "c" (^LCDVideoPlayer),
	renderFrame:      proc "c" (^LCDVideoPlayer, i32) -> i32,
	getError:         proc "c" (^LCDVideoPlayer) -> cstring,
	getInfo:          proc "c" (^LCDVideoPlayer, ^i32, ^i32, ^f32, ^i32, ^i32),
	getContext:       proc "c" (^LCDVideoPlayer) -> ^LCDBitmap,
}

videostream :: struct {
	newPlayer:             proc "c" () -> ^LCDStreamPlayer,
	freePlayer:            proc "c" (^LCDStreamPlayer),
	setBufferSize:         proc "c" (^LCDStreamPlayer, i32, i32),
	setFile:               proc "c" (^LCDStreamPlayer, ^i32),
	setHTTPConnection:     proc "c" (^LCDStreamPlayer, ^HTTPConnection),
	getFilePlayer:         proc "c" (^LCDStreamPlayer) -> ^FilePlayer,
	getVideoPlayer:        proc "c" (^LCDStreamPlayer) -> ^LCDVideoPlayer,

	// returns true if it drew a frame, else false
	bool: proc "c" (^i32) -> proc "c" (^LCDStreamPlayer) -> i32,
	getBufferedFrameCount: proc "c" (^LCDStreamPlayer) -> i32,
	uint32_t:              proc "c" (^i32) -> proc "c" (^LCDStreamPlayer) -> i32,

	// 3.0
	setTCPConnection: proc "c" (^LCDStreamPlayer, ^TCPConnection),
}

tilemap :: struct {
	newTilemap:        proc "c" () -> ^LCDTileMap,
	freeTilemap:       proc "c" (^LCDTileMap),
	setImageTable:     proc "c" (^LCDTileMap, ^LCDBitmapTable),
	getImageTable:     proc "c" (^LCDTileMap) -> ^LCDBitmapTable,
	setSize:           proc "c" (^LCDTileMap, i32, i32),
	getSize:           proc "c" (^LCDTileMap, ^i32, ^i32),
	getPixelSize:      proc "c" (^LCDTileMap, ^i32, ^i32),
	setTiles:          proc "c" (^LCDTileMap, ^i32, i32, i32),
	setTileAtPosition: proc "c" (^LCDTileMap, i32, i32, i32),
	getTileAtPosition: proc "c" (^LCDTileMap, i32, i32) -> i32,
	drawAtPoint:       proc "c" (^LCDTileMap, f32, f32),
}

graphics :: struct {
	video:                 ^video,

	// Drawing Functions
	clear: proc "c" (LCDColor),
	setBackgroundColor:    proc "c" (LCDSolidColor),
	setStencil:            proc "c" (^LCDBitmap),                                  // deprecated in favor of setStencilImage, which adds a "tile" flag
	setDrawMode:           proc "c" (LCDBitmapDrawMode) -> LCDBitmapDrawMode,
	setDrawOffset:         proc "c" (i32, i32),
	setClipRect:           proc "c" (i32, i32, i32, i32),
	clearClipRect:         proc "c" (),
	setLineCapStyle:       proc "c" (LCDLineCapStyle),
	setFont:               proc "c" (^LCDFont),
	setTextTracking:       proc "c" (i32),
	pushContext:           proc "c" (^LCDBitmap),
	popContext:            proc "c" (),
	drawBitmap:            proc "c" (^LCDBitmap, i32, i32, LCDBitmapFlip),
	tileBitmap:            proc "c" (^LCDBitmap, i32, i32, i32, i32, LCDBitmapFlip),
	drawLine:              proc "c" (i32, i32, i32, i32, i32, LCDColor),
	fillTriangle:          proc "c" (i32, i32, i32, i32, i32, i32, LCDColor),
	drawRect:              proc "c" (i32, i32, i32, i32, LCDColor),
	fillRect:              proc "c" (i32, i32, i32, i32, LCDColor),
	drawEllipse:           proc "c" (i32, i32, i32, i32, i32, f32, f32, LCDColor), // stroked inside the rect
	fillEllipse:           proc "c" (i32, i32, i32, i32, f32, f32, LCDColor),
	drawScaledBitmap:      proc "c" (^LCDBitmap, i32, i32, f32, f32),
	drawText:              proc "c" (rawptr, i32, PDStringEncoding, i32, i32) -> i32,

	// LCDBitmap
	newBitmap: proc "c" (i32, i32, LCDColor) -> ^LCDBitmap,
	freeBitmap:            proc "c" (^LCDBitmap),
	loadBitmap:            proc "c" (cstring, [^]cstring) -> ^LCDBitmap,
	copyBitmap:            proc "c" (^LCDBitmap) -> ^LCDBitmap,
	loadIntoBitmap:        proc "c" (cstring, ^LCDBitmap, [^]cstring),
	getBitmapData:         proc "c" (^LCDBitmap, ^i32, ^i32, ^i32, ^^i32, ^^i32),
	clearBitmap:           proc "c" (^LCDBitmap, LCDColor),
	rotatedBitmap:         proc "c" (^LCDBitmap, f32, f32, f32, ^i32) -> ^LCDBitmap,

	// LCDBitmapTable
	newBitmapTable: proc "c" (i32, i32, i32) -> ^LCDBitmapTable,
	freeBitmapTable:       proc "c" (^LCDBitmapTable),
	loadBitmapTable:       proc "c" (cstring, [^]cstring) -> ^LCDBitmapTable,
	loadIntoBitmapTable:   proc "c" (cstring, ^LCDBitmapTable, [^]cstring),
	getTableBitmap:        proc "c" (^LCDBitmapTable, i32) -> ^LCDBitmap,

	// LCDFont
	loadFont: proc "c" (cstring, [^]cstring) -> ^LCDFont,
	getFontPage:           proc "c" (^LCDFont, i32) -> ^LCDFontPage,
	getPageGlyph:          proc "c" (^LCDFontPage, i32, ^^LCDBitmap, ^i32) -> ^LCDFontGlyph,
	getGlyphKerning:       proc "c" (^LCDFontGlyph, i32, i32) -> i32,
	getTextWidth:          proc "c" (^LCDFont, rawptr, i32, PDStringEncoding, i32) -> i32,
	getFrame:              proc "c" () -> ^i32,                                    // row stride = LCD_ROWSIZE
	getDisplayFrame:       proc "c" () -> ^i32,                                    // row stride = LCD_ROWSIZE
	getDebugBitmap:        proc "c" () -> ^LCDBitmap,                              // valid in simulator only, function is NULL on device
	copyFrameBufferBitmap: proc "c" () -> ^LCDBitmap,
	markUpdatedRows:       proc "c" (i32, i32),
	display:               proc "c" (),

	// misc util.
	setColorToPattern: proc "c" (^LCDColor, ^LCDBitmap, i32, i32),
	checkMaskCollision:    proc "c" (^LCDBitmap, i32, i32, LCDBitmapFlip, ^LCDBitmap, i32, i32, LCDBitmapFlip, LCDRect) -> i32,

	// 1.1
	setScreenClipRect: proc "c" (i32, i32, i32, i32),

	// 1.1.1
	fillPolygon: proc "c" (i32, ^i32, LCDColor, LCDPolygonFillRule),
	uint8_t:               proc "c" (^i32) -> proc "c" (^LCDFont) -> i32,

	// 1.7
	getDisplayBufferBitmap: proc "c" () -> ^LCDBitmap,
	drawRotatedBitmap:     proc "c" (^LCDBitmap, i32, i32, f32, f32, f32, f32, f32),
	setTextLeading:        proc "c" (i32),

	// 1.8
	setBitmapMask: proc "c" (^LCDBitmap, ^LCDBitmap) -> i32,
	getBitmapMask:         proc "c" (^LCDBitmap) -> ^LCDBitmap,

	// 1.10
	setStencilImage: proc "c" (^LCDBitmap, i32),

	// 1.12
	makeFontFromData: proc "c" (^LCDFontData, i32) -> ^LCDFont,

	// 2.1
	getTextTracking: proc "c" () -> i32,

	// 2.5
	setPixel: proc "c" (i32, i32, LCDColor),
	getBitmapPixel:        proc "c" (^LCDBitmap, i32, i32) -> LCDSolidColor,
	getBitmapTableInfo:    proc "c" (^LCDBitmapTable, ^i32, ^i32),

	// 2.6
	drawTextInRect: proc "c" (rawptr, i32, PDStringEncoding, i32, i32, i32, i32, PDTextWrappingMode, PDTextAlignment),

	// 2.7
	getTextHeightForMaxWidth: proc "c" (^LCDFont, rawptr, i32, i32, PDStringEncoding, PDTextWrappingMode, i32, i32) -> i32,
	drawRoundRect:         proc "c" (i32, i32, i32, i32, i32, i32, LCDColor),
	fillRoundRect:         proc "c" (i32, i32, i32, i32, i32, LCDColor),

	// 3.0
	tilemap: ^tilemap,
	videostream:           ^videostream,
}


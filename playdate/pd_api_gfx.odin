//
//  pdext_gfx.h
//  Playdate Simulator
//
//  Created by Dave Hayden on 10/6/17.
//  Copyright © 2017 Panic, Inc. All rights reserved.
//
package playdate

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

LCDPattern :: [16]i32 // 8x8 pattern: 8 rows image data, 8 rows mask
LCDColor   :: i32     // LCDSolidColor or pointer to LCDPattern

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
	setFile:           proc "c" (p: ^LCDStreamPlayer, file: ^i32),
	setHTTPConnection: proc "c" (p: ^LCDStreamPlayer, conn: ^HTTPConnection),
	getFilePlayer:     proc "c" (p: ^LCDStreamPlayer) -> ^FilePlayer,
	getVideoPlayer:    proc "c" (p: ^LCDStreamPlayer) -> ^LCDVideoPlayer,

	//	int (*setContext)(LCDStreamPlayer* p, LCDBitmap* context);
	//	LCDBitmap* (*getContext)(LCDStreamPlayer* p);
	
	// returns true if it drew a frame, else false
	update: proc "c" (p: ^LCDStreamPlayer) -> bool,
	getBufferedFrameCount: proc "c" (p: ^LCDStreamPlayer) -> i32,
	uint32_t:              proc "c" (p: ^LCDStreamPlayer, getBytesRead: ^i32) -> proc "c" (p: ^LCDStreamPlayer) -> i32,

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
	getPixelSize:      proc "c" (m: ^LCDTileMap, outWidth: ^i32, outHeight: ^i32),
	setTiles:          proc "c" (m: ^LCDTileMap, indexes: ^i32, count: i32, rowwidth: i32),
	setTileAtPosition: proc "c" (m: ^LCDTileMap, x: i32, y: i32, idx: i32),
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
	drawText:           proc "c" (text: rawptr, len: i32, encoding: PDStringEncoding, x: i32, y: i32) -> i32,

	// LCDBitmap
	newBitmap:      proc "c" (width: i32, height: i32, bgcolor: LCDColor) -> ^LCDBitmap,
	freeBitmap:     proc "c" (^LCDBitmap),
	loadBitmap:     proc "c" (path: cstring, outerr: ^cstring) -> ^LCDBitmap,
	copyBitmap:     proc "c" (bitmap: ^LCDBitmap) -> ^LCDBitmap,
	loadIntoBitmap: proc "c" (path: cstring, bitmap: ^LCDBitmap, outerr: ^cstring),
	getBitmapData:  proc "c" (bitmap: ^LCDBitmap, width: ^i32, height: ^i32, rowbytes: ^i32, mask: ^^i32, data: ^^i32),
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
	getFontPage:     proc "c" (font: ^LCDFont, _c: i32) -> ^LCDFontPage,
	getPageGlyph:    proc "c" (page: ^LCDFontPage, _c: i32, bitmap: ^^LCDBitmap, advance: ^i32) -> ^LCDFontGlyph,
	getGlyphKerning: proc "c" (glyph: ^LCDFontGlyph, glyphcode: i32, nextcode: i32) -> i32,
	getTextWidth:    proc "c" (font: ^LCDFont, text: rawptr, len: i32, encoding: PDStringEncoding, tracking: i32) -> i32,

	// raw framebuffer access
	getFrame:              proc "c" () -> ^i32,       // row stride = LCD_ROWSIZE
	getDisplayFrame:       proc "c" () -> ^i32,       // row stride = LCD_ROWSIZE
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
	fillPolygon: proc "c" (nPoints: i32, coords: ^i32, color: LCDColor, fillrule: LCDPolygonFillRule),
	uint8_t:     proc "c" (font: ^LCDFont, getFontHeight: ^i32) -> proc "c" (^LCDFont) -> i32,

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
	drawTextInRect: proc "c" (text: rawptr, len: i32, encoding: PDStringEncoding, x: i32, y: i32, width: i32, height: i32, wrap: PDTextWrappingMode, align: PDTextAlignment),

	// 2.7
	getTextHeightForMaxWidth: proc "c" (font: ^LCDFont, text: rawptr, len: i32, maxwidth: i32, encoding: PDStringEncoding, wrap: PDTextWrappingMode, tracking: i32, extraLeading: i32) -> i32,
	drawRoundRect:            proc "c" (x: i32, y: i32, width: i32, height: i32, radius: i32, lineWidth: i32, color: LCDColor),
	fillRoundRect:            proc "c" (x: i32, y: i32, width: i32, height: i32, radius: i32, color: LCDColor),

	// 3.0
	tilemap:     ^tilemap,
	videostream: ^videostream,
}


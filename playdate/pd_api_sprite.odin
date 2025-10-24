//
//  pdext_gfx.h
//  Playdate Simulator
//
//  Created by Dave Hayden on 10/6/17.
//  Copyright © 2017 Panic, Inc. All rights reserved.
//
package playdate

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
	sprite:       ^i32,                        // The sprite being moved
	other:        ^i32,                        // The sprite colliding with the sprite being moved
	responseType: SpriteCollisionResponseType, // The result of collisionResponse
	overlaps:     i32,                         // True if the sprite was overlapping other when the collision started. False if it didn’t overlap but tunneled through other.
	ti:           f32,                         // A number between 0 and 1 indicating how far along the movement to the goal the collision occurred
	move:         CollisionPoint,              // The difference between the original coordinates and the actual ones when the collision happened
	normal:       CollisionVector,             // The collision normal; usually -1, 0, or 1 in x and y. Use this value to determine things like if your character is touching the ground.
	touch:        CollisionPoint,              // The coordinates where the sprite started touching other
	spriteRect:   PDRect,                      // The rectangle the sprite occupied when the touch happened
	otherRect:    PDRect,                      // The rectangle the sprite being collided with occupied when the touch happened
}

SpriteQueryInfo :: struct {
	sprite: ^i32, // The sprite being intersected by the segment

	// ti1 and ti2 are numbers between 0 and 1 which indicate how far from the starting point of the line segment the collision happened
	ti1:        f32,            // entry point
	ti2:        f32,            // exit point
	entryPoint: CollisionPoint, // The coordinates of the first intersection between sprite and the line segment
	exitPoint:  CollisionPoint, // The coordinates of the second intersection between sprite and the line segment
}

LCDSprite                    :: struct {}
CWCollisionInfo              :: struct {}
CWItemInfo                   :: struct {}
LCDSpriteDrawFunction        :: proc "c" (sprite: ^LCDSprite, bounds: PDRect, drawrect: PDRect)
LCDSpriteUpdateFunction      :: proc "c" (sprite: ^LCDSprite)
LCDSpriteCollisionFilterProc :: proc "c" (sprite: ^LCDSprite, other: ^LCDSprite) -> SpriteCollisionResponseType

sprite :: struct {
	setAlwaysRedraw:       proc "c" (flag: i32),
	addDirtyRect:          proc "c" (dirtyRect: i32),
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
	setImage:              proc "c" (sprite: ^LCDSprite, image: ^i32, flip: i32),
	getImage:              proc "c" (sprite: ^LCDSprite) -> ^i32,
	setSize:               proc "c" (s: ^LCDSprite, width: f32, height: f32),
	setZIndex:             proc "c" (sprite: ^LCDSprite, zIndex: i32),
	int16_t:               proc "c" (sprite: ^LCDSprite, getZIndex: ^i32) -> proc "c" (^LCDSprite) -> i32,
	setDrawMode:           proc "c" (sprite: ^LCDSprite, mode: i32),
	setImageFlip:          proc "c" (sprite: ^LCDSprite, flip: i32),
	LCDBitmapFlip:         proc "c" (sprite: ^LCDSprite, getImageFlip: ^i32) -> proc "c" (^LCDSprite) -> i32,
	setStencil:            proc "c" (sprite: ^LCDSprite, stencil: ^i32), // deprecated in favor of setStencilImage()
	setClipRect:           proc "c" (sprite: ^LCDSprite, clipRect: i32),
	clearClipRect:         proc "c" (sprite: ^LCDSprite),
	setClipRectsInRange:   proc "c" (clipRect: i32, startZ: i32, endZ: i32),
	clearClipRectsInRange: proc "c" (startZ: i32, endZ: i32),
	setUpdatesEnabled:     proc "c" (sprite: ^LCDSprite, flag: i32),
	updatesEnabled:        proc "c" (sprite: ^LCDSprite) -> i32,
	setCollisionsEnabled:  proc "c" (sprite: ^LCDSprite, flag: i32),
	collisionsEnabled:     proc "c" (sprite: ^LCDSprite) -> i32,
	setVisible:            proc "c" (sprite: ^LCDSprite, flag: i32),
	isVisible:             proc "c" (sprite: ^LCDSprite) -> i32,
	setOpaque:             proc "c" (sprite: ^LCDSprite, flag: i32),
	markDirty:             proc "c" (sprite: ^LCDSprite),
	setTag:                proc "c" (sprite: ^LCDSprite, tag: i32),
	uint8_t:               proc "c" (sprite: ^LCDSprite, getTag: ^i32) -> proc "c" (sprite: ^LCDSprite) -> i32,
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
	setStencilPattern: proc "c" (sprite: ^LCDSprite, pattern: ^[8]i32),
	clearStencil:      proc "c" (sprite: ^LCDSprite),
	setUserdata:       proc "c" (sprite: ^LCDSprite, userdata: rawptr),
	getUserdata:       proc "c" (sprite: ^LCDSprite) -> rawptr,

	// added in 1.10
	setStencilImage: proc "c" (sprite: ^LCDSprite, stencil: ^i32, tile: i32),

	// 2.1
	setCenter: proc "c" (s: ^LCDSprite, x: f32, y: f32),
	getCenter: proc "c" (s: ^LCDSprite, x: ^f32, y: ^f32),

	// 2.7
	setTilemap: proc "c" (s: ^LCDSprite, tilemap: ^i32),
	getTilemap: proc "c" (s: ^LCDSprite) -> ^i32,
}


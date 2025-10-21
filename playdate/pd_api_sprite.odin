//
//  pdext_gfx.h
//  Playdate Simulator
//
//  Created by Dave Hayden on 10/6/17.
//  Copyright © 2017 Panic, Inc. All rights reserved.
//
package playdate





// pdext_sprite_h :: 

SpriteCollisionResponseType :: enum u32 {
	Slide,
	Freeze,
	Overlap,
	Bounce,
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
	sprite:     ^i32,           // The sprite being intersected by the segment
	ti1:        f32,            // entry point
	ti2:        f32,            // exit point
	entryPoint: CollisionPoint, // The coordinates of the first intersection between sprite and the line segment
	exitPoint:  CollisionPoint, // The coordinates of the second intersection between sprite and the line segment
}

LCDSprite :: struct {}

CWCollisionInfo :: struct {}

CWItemInfo :: struct {}

LCDSpriteDrawFunction :: proc "c" (^LCDSprite, PDRect, PDRect)

LCDSpriteUpdateFunction :: proc "c" (^LCDSprite)

LCDSpriteCollisionFilterProc :: proc "c" (^LCDSprite, ^LCDSprite) -> SpriteCollisionResponseType

sprite :: struct {
	setAlwaysRedraw:          proc "c" (i32),
	addDirtyRect:             proc "c" (i32),
	drawSprites:              proc "c" (),
	updateAndDrawSprites:     proc "c" (),
	newSprite:                proc "c" () -> ^LCDSprite,
	freeSprite:               proc "c" (^LCDSprite),
	copy:                     proc "c" (^LCDSprite) -> ^LCDSprite,
	addSprite:                proc "c" (^LCDSprite),
	removeSprite:             proc "c" (^LCDSprite),
	removeSprites:            proc "c" (^^LCDSprite, i32),
	removeAllSprites:         proc "c" (),
	getSpriteCount:           proc "c" () -> i32,
	setBounds:                proc "c" (^LCDSprite, PDRect),
	getBounds:                proc "c" (^LCDSprite) -> PDRect,
	moveTo:                   proc "c" (^LCDSprite, f32, f32),
	moveBy:                   proc "c" (^LCDSprite, f32, f32),
	setImage:                 proc "c" (^LCDSprite, ^i32, i32),
	getImage:                 proc "c" (^LCDSprite) -> ^i32,
	setSize:                  proc "c" (^LCDSprite, f32, f32),
	setZIndex:                proc "c" (^LCDSprite, i32),
	int16_t:                  proc "c" (^i32) -> proc "c" (^LCDSprite) -> i32,
	setDrawMode:              proc "c" (^LCDSprite, i32),
	setImageFlip:             proc "c" (^LCDSprite, i32),
	LCDBitmapFlip:            proc "c" (^i32) -> proc "c" (^LCDSprite) -> i32,
	setStencil:               proc "c" (^LCDSprite, ^i32),                                               // deprecated in favor of setStencilImage()
	setClipRect:              proc "c" (^LCDSprite, i32),
	clearClipRect:            proc "c" (^LCDSprite),
	setClipRectsInRange:      proc "c" (i32, i32, i32),
	clearClipRectsInRange:    proc "c" (i32, i32),
	setUpdatesEnabled:        proc "c" (^LCDSprite, i32),
	updatesEnabled:           proc "c" (^LCDSprite) -> i32,
	setCollisionsEnabled:     proc "c" (^LCDSprite, i32),
	collisionsEnabled:        proc "c" (^LCDSprite) -> i32,
	setVisible:               proc "c" (^LCDSprite, i32),
	isVisible:                proc "c" (^LCDSprite) -> i32,
	setOpaque:                proc "c" (^LCDSprite, i32),
	markDirty:                proc "c" (^LCDSprite),
	setTag:                   proc "c" (^LCDSprite, i32),
	uint8_t:                  proc "c" (^i32) -> proc "c" (^LCDSprite) -> i32,
	setIgnoresDrawOffset:     proc "c" (^LCDSprite, i32),
	setUpdateFunction:        proc "c" (^LCDSprite, LCDSpriteUpdateFunction),
	setDrawFunction:          proc "c" (^LCDSprite, LCDSpriteDrawFunction),
	getPosition:              proc "c" (^LCDSprite, ^f32, ^f32),

	// Collisions
	resetCollisionWorld: proc "c" (),
	setCollideRect:           proc "c" (^LCDSprite, PDRect),
	getCollideRect:           proc "c" (^LCDSprite) -> PDRect,
	clearCollideRect:         proc "c" (^LCDSprite),

	// caller is responsible for freeing the returned array for all collision methods
	setCollisionResponseFunction: proc "c" (^LCDSprite, LCDSpriteCollisionFilterProc),
	checkCollisions:          proc "c" (^LCDSprite, f32, f32, ^f32, ^f32, ^i32) -> ^SpriteCollisionInfo, // access results using SpriteCollisionInfo *info = &results[i];
	moveWithCollisions:       proc "c" (^LCDSprite, f32, f32, ^f32, ^f32, ^i32) -> ^SpriteCollisionInfo,
	querySpritesAtPoint:      proc "c" (f32, f32, ^i32) -> ^^LCDSprite,
	querySpritesInRect:       proc "c" (f32, f32, f32, f32, ^i32) -> ^^LCDSprite,
	querySpritesAlongLine:    proc "c" (f32, f32, f32, f32, ^i32) -> ^^LCDSprite,
	querySpriteInfoAlongLine: proc "c" (f32, f32, f32, f32, ^i32) -> ^SpriteQueryInfo,                   // access results using SpriteQueryInfo *info = &results[i];
	overlappingSprites:       proc "c" (^LCDSprite, ^i32) -> ^^LCDSprite,
	allOverlappingSprites:    proc "c" (^i32) -> ^^LCDSprite,

	// added in 1.7
	setStencilPattern: proc "c" (^LCDSprite, #by_ptr [8]i32),
	clearStencil:             proc "c" (^LCDSprite),
	setUserdata:              proc "c" (^LCDSprite, rawptr),
	getUserdata:              proc "c" (^LCDSprite) -> rawptr,

	// added in 1.10
	setStencilImage: proc "c" (^LCDSprite, ^i32, i32),

	// 2.1
	setCenter: proc "c" (^LCDSprite, f32, f32),
	getCenter:                proc "c" (^LCDSprite, ^f32, ^f32),

	// 2.7
	setTilemap: proc "c" (^LCDSprite, ^i32),
	getTilemap:               proc "c" (^LCDSprite) -> ^i32,
}


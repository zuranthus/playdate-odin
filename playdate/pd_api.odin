//
//  pd_api.h
//  Playdate C API
//
//  Created by Dave Hayden on 7/30/14.
//  Copyright (c) 2014 Panic, Inc. All rights reserved.
//
package playdate

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


//
//  pd_api.h
//  Playdate C API
//
//  Created by Dave Hayden on 7/30/14.
//  Copyright (c) 2014 Panic, Inc. All rights reserved.
//
package playdate





// PLAYDATEAPI_H :: 

PlaydateAPI :: struct {
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
	Init,
	InitLua,
	Lock,
	Unlock,
	Pause,
	Resume,
	Terminate,
	KeyPressed, // arg is keycode
	KeyReleased,
	LowPower,
	MirrorStarted,
	MirrorEnded,
}


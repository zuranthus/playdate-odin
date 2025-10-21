//
//  pdext_display.h
//  Playdate Simulator
//
//  Created by Dave Hayden on 10/6/17.
//  Copyright © 2017 Panic, Inc. All rights reserved.
//
package playdate





// pdext_display_h :: 

display :: struct {
	getWidth:       proc "c" () -> i32,
	getHeight:      proc "c" () -> i32,
	setRefreshRate: proc "c" (f32),
	setInverted:    proc "c" (i32),
	setScale:       proc "c" (u32),
	setMosaic:      proc "c" (u32, u32),
	setFlipped:     proc "c" (i32, i32),
	setOffset:      proc "c" (i32, i32),

	// 2.7
	getRefreshRate: proc "c" () -> f32,
	getFPS:         proc "c" () -> f32,
}


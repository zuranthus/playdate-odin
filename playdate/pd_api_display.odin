//
//  pdext_display.h
//  Playdate Simulator
//
//  Created by Dave Hayden on 10/6/17.
//  Copyright © 2017 Panic, Inc. All rights reserved.
//
package playdate

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


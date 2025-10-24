//
//  pdext_lua.h
//  Playdate Simulator
//
//  Created by Dave Hayden on 10/6/17.
//  Copyright © 2017 Panic, Inc. All rights reserved.
//
package playdate

lua_State     :: rawptr
lua_CFunction :: proc "c" (L: ^lua_State) -> i32
LuaUDObject   :: struct {}

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
	getArgBytes:  proc "c" (pos: i32, outlen: ^i32) -> cstring,
	getArgObject: proc "c" (pos: i32, type: cstring, outud: ^^LuaUDObject) -> rawptr,
	getBitmap:    proc "c" (pos: i32) -> ^i32,
	getSprite:    proc "c" (pos: i32) -> ^LCDSprite,

	// for returning values back to Lua
	pushNil:       proc "c" (),
	pushBool:      proc "c" (val: i32),
	pushInt:       proc "c" (val: i32),
	pushFloat:     proc "c" (val: f32),
	pushString:    proc "c" (str: cstring),
	pushBytes:     proc "c" (str: cstring, len: i32),
	pushBitmap:    proc "c" (bitmap: ^i32),
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


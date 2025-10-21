//
//  pdext_lua.h
//  Playdate Simulator
//
//  Created by Dave Hayden on 10/6/17.
//  Copyright © 2017 Panic, Inc. All rights reserved.
//
package playdate





// pdext_lua_h :: 

lua_State :: rawptr

lua_CFunction :: proc "c" (^lua_State) -> i32

LuaUDObject :: struct {}


l_valtype :: enum u32 {
	Int,
	Float,
	Str,
}

lua_reg :: struct {
	name: cstring,
	func: lua_CFunction,
}

LuaType :: enum u32 {
	Nil,
	Bool,
	Int,
	Float,
	String,
	Table,
	Function,
	Thread,
	Object,
}

lua_val :: struct {
	name: cstring,
	type: l_valtype,
	v:    struct #raw_union {
		intval:   u32,
		floatval: f32,
		strval:   cstring,
	},
}

lua :: struct {
	// these two return 1 on success, else 0 with an error message in outErr
	addFunction: proc "c" (lua_CFunction, cstring, [^]cstring) -> i32,
	registerClass:  proc "c" (cstring, ^lua_reg, ^lua_val, i32, [^]cstring) -> i32,
	pushFunction:   proc "c" (lua_CFunction),
	indexMetatable: proc "c" () -> i32,
	stop:           proc "c" (),
	start:          proc "c" (),

	// stack operations
	getArgCount: proc "c" () -> i32,
	getArgType:     proc "c" (i32, [^]cstring) -> LuaType,
	argIsNil:       proc "c" (i32) -> i32,
	getArgBool:     proc "c" (i32) -> i32,
	getArgInt:      proc "c" (i32) -> i32,
	getArgFloat:    proc "c" (i32) -> f32,
	getArgString:   proc "c" (i32) -> cstring,
	getArgBytes:    proc "c" (i32, ^i32) -> cstring,
	getArgObject:   proc "c" (i32, cstring, ^^LuaUDObject) -> rawptr,
	getBitmap:      proc "c" (i32) -> ^i32,
	getSprite:      proc "c" (i32) -> ^LCDSprite,

	// for returning values back to Lua
	pushNil: proc "c" (),
	pushBool:       proc "c" (i32),
	pushInt:        proc "c" (i32),
	pushFloat:      proc "c" (f32),
	pushString:     proc "c" (cstring),
	pushBytes:      proc "c" (cstring, i32),
	pushBitmap:     proc "c" (^i32),
	pushSprite:     proc "c" (^LCDSprite),
	pushObject:     proc "c" (rawptr, cstring, i32) -> ^LuaUDObject,
	retainObject:   proc "c" (^LuaUDObject) -> ^LuaUDObject,
	releaseObject:  proc "c" (^LuaUDObject),
	setUserValue:   proc "c" (^LuaUDObject, u32),        // sets item on top of stack and pops it
	getUserValue:   proc "c" (^LuaUDObject, u32) -> i32, // pushes item at slot to top of stack, returns stack position

	// calling lua from C has some overhead. use sparingly!
	callFunction_deprecated: proc "c" (cstring, i32),
	callFunction:   proc "c" (cstring, i32, [^]cstring) -> i32,
}


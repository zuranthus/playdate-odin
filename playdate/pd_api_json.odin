//
//  pdext_json.h
//  Playdate Simulator
//
//  Created by Dave Hayden on 10/6/17.
//  Copyright © 2017 Panic, Inc. All rights reserved.
//
package playdate





// pdext_json_h :: 

json_value_type :: enum u32 {
	Null,
	True,
	False,
	Integer,
	Float,
	String,
	Array,
	Table,
}

json_value :: struct {
	type: i8,
	data: struct #raw_union {
		intval:    i32,
		floatval:  f32,
		stringval: cstring,
		arrayval:  rawptr,
		tableval:  rawptr,
	},
}

json_decoder :: struct {
	decodeError:                   proc "c" (^json_decoder, cstring, i32),

	// the following functions are each optional
	willDecodeSublist: proc "c" (^json_decoder, cstring, json_value_type),
	shouldDecodeTableValueForKey:  proc "c" (^json_decoder, cstring) -> i32,
	didDecodeTableValue:           proc "c" (^json_decoder, cstring, json_value),
	shouldDecodeArrayValueAtIndex: proc "c" (^json_decoder, i32) -> i32,
	didDecodeArrayValue:           proc "c" (^json_decoder, i32, json_value), // if pos==0, this was a bare value at the root of the file
	didDecodeSublist:              proc "c" (^json_decoder, cstring, json_value_type) -> rawptr,
	userdata:                      rawptr,
	returnString:                  i32,                                       // when set, the decoder skips parsing and returns the current subtree as a string
	path:                          cstring,                                   // updated during parsing, reflects current position in tree
}

// fill buffer, return bytes written or -1 on end of data
json_readFunc :: proc "c" (rawptr, ^i32, i32) -> i32

json_reader :: struct {
	read:     json_readFunc,
	userdata: rawptr, // passed back to the read function above
}

// encoder
json_writeFunc :: proc "c" (rawptr, cstring, i32)

json_encoder :: struct {
	writeStringFunc: json_writeFunc,
	userdata:        rawptr,
	pretty:          i32,
	startedTable:    i32,
	startedArray:    i32,
	depth:           i32,
	startArray:      proc "c" (^json_encoder),
	addArrayMember:  proc "c" (^json_encoder),
	endArray:        proc "c" (^json_encoder),
	startTable:      proc "c" (^json_encoder),
	addTableMember:  proc "c" (^json_encoder, cstring, i32),
	endTable:        proc "c" (^json_encoder),
	writeNull:       proc "c" (^json_encoder),
	writeFalse:      proc "c" (^json_encoder),
	writeTrue:       proc "c" (^json_encoder),
	writeInt:        proc "c" (^json_encoder, i32),
	writeDouble:     proc "c" (^json_encoder, f64),
	writeString:     proc "c" (^json_encoder, cstring, i32),
}

json :: struct {
	initEncoder:  proc "c" (^json_encoder, json_writeFunc, rawptr, i32),
	decode:       proc "c" (^json_decoder, json_reader, ^json_value) -> i32,
	decodeString: proc "c" (^json_decoder, cstring, ^json_value) -> i32,
}


//
//  pdext_json.h
//  Playdate Simulator
//
//  Created by Dave Hayden on 10/6/17.
//  Copyright © 2017 Panic, Inc. All rights reserved.
//
package playdate

json_value_type :: enum u32 {
	Null    = 0,
	True    = 1,
	False   = 2,
	Integer = 3,
	Float   = 4,
	String  = 5,
	Array   = 6,
	Table   = 7,
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
	decodeError: proc "c" (decoder: ^json_decoder, error: cstring, linenum: i32),

	// the following functions are each optional
	willDecodeSublist:             proc "c" (decoder: ^json_decoder, name: cstring, type: json_value_type),
	shouldDecodeTableValueForKey:  proc "c" (decoder: ^json_decoder, key: cstring) -> i32,
	didDecodeTableValue:           proc "c" (decoder: ^json_decoder, key: cstring, value: json_value),
	shouldDecodeArrayValueAtIndex: proc "c" (decoder: ^json_decoder, pos: i32) -> i32,
	didDecodeArrayValue:           proc "c" (decoder: ^json_decoder, pos: i32, value: json_value), // if pos==0, this was a bare value at the root of the file
	didDecodeSublist:              proc "c" (decoder: ^json_decoder, name: cstring, type: json_value_type) -> rawptr,
	userdata:                      rawptr,
	returnString:                  i32,                                                            // when set, the decoder skips parsing and returns the current subtree as a string
	path:                          cstring,                                                        // updated during parsing, reflects current position in tree
}

// fill buffer, return bytes written or -1 on end of data
json_readFunc :: proc "c" (userdata: rawptr, buf: ^i32, bufsize: i32) -> i32

json_reader :: struct {
	read:     json_readFunc,
	userdata: rawptr, // passed back to the read function above
}

// encoder
json_writeFunc :: proc "c" (userdata: rawptr, str: cstring, len: i32)

json_encoder :: struct {
	writeStringFunc: json_writeFunc,
	userdata:        rawptr,
	pretty:          i32,
	startedTable:    i32,
	startedArray:    i32,
	depth:           i32,
	startArray:      proc "c" (encoder: ^json_encoder),
	addArrayMember:  proc "c" (encoder: ^json_encoder),
	endArray:        proc "c" (encoder: ^json_encoder),
	startTable:      proc "c" (encoder: ^json_encoder),
	addTableMember:  proc "c" (encoder: ^json_encoder, name: cstring, len: i32),
	endTable:        proc "c" (encoder: ^json_encoder),
	writeNull:       proc "c" (encoder: ^json_encoder),
	writeFalse:      proc "c" (encoder: ^json_encoder),
	writeTrue:       proc "c" (encoder: ^json_encoder),
	writeInt:        proc "c" (encoder: ^json_encoder, num: i32),
	writeDouble:     proc "c" (encoder: ^json_encoder, num: f64),
	writeString:     proc "c" (encoder: ^json_encoder, str: cstring, len: i32),
}

json :: struct {
	initEncoder:  proc "c" (encoder: ^json_encoder, write: json_writeFunc, userdata: rawptr, pretty: i32),
	decode:       proc "c" (functions: ^json_decoder, reader: json_reader, outval: ^json_value) -> i32,
	decodeString: proc "c" (functions: ^json_decoder, jsonString: cstring, outval: ^json_value) -> i32,
}


//
//  pdext_file.h
//  Playdate Simulator
//
//  Created by Dave Hayden on 10/6/17.
//  Copyright © 2017 Panic, Inc. All rights reserved.
//
package playdate

SDFile :: struct {}

FileOption :: enum u32 {
	Read     = 0,
	ReadData = 1,
	Write    = 2,
	Append   = 3,
}

FileOptions :: bit_set[FileOption; i32]

FileStat :: struct {
	isdir:    i32,
	size:     u32,
	m_year:   i32,
	m_month:  i32,
	m_day:    i32,
	m_hour:   i32,
	m_minute: i32,
	m_second: i32,
}

SEEK_SET        :: 0       /* Seek from beginning of file.  */
SEEK_CUR        :: 1       /* Seek from current position.  */
SEEK_END        :: 2       /* Set file pointer to EOF plus "offset" */

file :: struct {
	geterr:    proc "c" () -> cstring,
	listfiles: proc "c" (path: cstring, callback: proc "c" (path: cstring, userdata: rawptr), userdata: rawptr, showhidden: i32) -> i32,
	stat:      proc "c" (path: cstring, stat: ^FileStat) -> i32,
	mkdir:     proc "c" (path: cstring) -> i32,
	unlink:    proc "c" (name: cstring, recursive: i32) -> i32,
	rename:    proc "c" (from: cstring, to: cstring) -> i32,
	open:      proc "c" (name: cstring, mode: FileOptions) -> ^SDFile,
	close:     proc "c" (file: ^SDFile) -> i32,
	read:      proc "c" (file: ^SDFile, buf: rawptr, len: u32) -> i32,
	write:     proc "c" (file: ^SDFile, buf: rawptr, len: u32) -> i32,
	flush:     proc "c" (file: ^SDFile) -> i32,
	tell:      proc "c" (file: ^SDFile) -> i32,
	seek:      proc "c" (file: ^SDFile, pos: i32, whence: i32) -> i32,
}


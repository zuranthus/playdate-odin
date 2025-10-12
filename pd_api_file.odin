//
//  pdext_file.h
//  Playdate Simulator
//
//  Created by Dave Hayden on 10/6/17.
//  Copyright © 2017 Panic, Inc. All rights reserved.
//
package playdate





// pdext_file_h :: 

SDFile :: struct {}

FileOptions :: enum u32 {
	Read     = 1,
	ReadData = 2,
	Write    = 4,
	Append   = 8,
}

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
/* Seek from beginning of file.  */
SEEK_CUR        :: 1       /* Seek from current position.  */
/* Seek from current position.  */
SEEK_END        :: 2       /* Set file pointer to EOF plus "offset" */

file :: struct {
	geterr:    proc "c" () -> cstring,
	listfiles: proc "c" (cstring, proc "c" (cstring, rawptr), rawptr, i32) -> i32,
	stat:      proc "c" (cstring, ^FileStat) -> i32,
	mkdir:     proc "c" (cstring) -> i32,
	unlink:    proc "c" (cstring, i32) -> i32,
	rename:    proc "c" (cstring, cstring) -> i32,
	open:      proc "c" (cstring, FileOptions) -> ^SDFile,
	close:     proc "c" (^SDFile) -> i32,
	read:      proc "c" (^SDFile, rawptr, u32) -> i32,
	write:     proc "c" (^SDFile, rawptr, u32) -> i32,
	flush:     proc "c" (^SDFile) -> i32,
	tell:      proc "c" (^SDFile) -> i32,
	seek:      proc "c" (^SDFile, i32, i32) -> i32,
}


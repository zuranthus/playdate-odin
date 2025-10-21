//
//  pd_api_http.h
//  Playdate Simulator
//
//  Created by Dave Hayden on 7/18/24.
//  Copyright © 2024 Panic, Inc. All rights reserved.
//
package playdate





// pd_api_http_h :: 

HTTPConnection :: struct {}

TCPConnection :: struct {}

PDNetErr :: enum i32 {
	OK                  = 0,
	NO_DEVICE           = -1,
	BUSY                = -2,
	WRITE_ERROR         = -3,
	WRITE_BUSY          = -4,
	WRITE_TIMEOUT       = -5,
	READ_ERROR          = -6,
	READ_BUSY           = -7,
	READ_TIMEOUT        = -8,
	READ_OVERFLOW       = -9,
	FRAME_ERROR         = -10,
	BAD_RESPONSE        = -11,
	ERROR_RESPONSE      = -12,
	RESET_TIMEOUT       = -13,
	BUFFER_TOO_SMALL    = -14,
	UNEXPECTED_RESPONSE = -15,
	NOT_CONNECTED_TO_AP = -16,
	NOT_IMPLEMENTED     = -17,
	CONNECTION_CLOSED   = -18,
}

WifiStatus :: enum u32 {
	NotConnected, //!< Not connected to an AP
	Connected,    //!< Device is connected to an AP
	NotAvailable, //!< A connection has been attempted and no configured AP was available
}

AccessRequestCallback :: proc "c" (i32, rawptr)

HTTPConnectionCallback :: proc "c" (^HTTPConnection)

HTTPHeaderCallback :: proc "c" (^HTTPConnection, cstring, cstring)

http :: struct {
	requestAccess:               proc "c" (cstring, i32, i32, cstring, AccessRequestCallback, rawptr) -> accessReply,
	newConnection:               proc "c" (cstring, i32, i32) -> ^HTTPConnection,
	retain:                      proc "c" (^HTTPConnection) -> ^HTTPConnection,
	release:                     proc "c" (^HTTPConnection),
	setConnectTimeout:           proc "c" (^HTTPConnection, i32),
	setKeepAlive:                proc "c" (^HTTPConnection, i32),
	setByteRange:                proc "c" (^HTTPConnection, i32, i32),
	setUserdata:                 proc "c" (^HTTPConnection, rawptr),
	getUserdata:                 proc "c" (^HTTPConnection) -> rawptr,
	get:                         proc "c" (^HTTPConnection, cstring, cstring, i32) -> PDNetErr,
	post:                        proc "c" (^HTTPConnection, cstring, cstring, i32, cstring, i32) -> PDNetErr,
	query:                       proc "c" (^HTTPConnection, cstring, cstring, cstring, i32, cstring, i32) -> PDNetErr,
	getError:                    proc "c" (^HTTPConnection) -> PDNetErr,
	getProgress:                 proc "c" (^HTTPConnection, ^i32, ^i32),
	getResponseStatus:           proc "c" (^HTTPConnection) -> i32,
	size_t:                      proc "c" (^i32) -> proc "c" (^HTTPConnection) -> i32,
	setReadTimeout:              proc "c" (^HTTPConnection, i32),
	setReadBufferSize:           proc "c" (^HTTPConnection, i32),
	read:                        proc "c" (^HTTPConnection, rawptr, u32) -> i32,
	close:                       proc "c" (^HTTPConnection),
	setHeaderReceivedCallback:   proc "c" (^HTTPConnection, HTTPHeaderCallback),
	setHeadersReadCallback:      proc "c" (^HTTPConnection, HTTPConnectionCallback),
	setResponseCallback:         proc "c" (^HTTPConnection, HTTPConnectionCallback),
	setRequestCompleteCallback:  proc "c" (^HTTPConnection, HTTPConnectionCallback),
	setConnectionClosedCallback: proc "c" (^HTTPConnection, HTTPConnectionCallback),
}

TCPConnectionCallback :: proc "c" (^TCPConnection, PDNetErr)

TCPOpenCallback :: proc "c" (^TCPConnection, PDNetErr, rawptr)

tcp :: struct {
	requestAccess:               proc "c" (cstring, i32, i32, cstring, AccessRequestCallback, rawptr) -> accessReply,
	newConnection:               proc "c" (cstring, i32, i32) -> ^TCPConnection,
	retain:                      proc "c" (^TCPConnection) -> ^TCPConnection,
	release:                     proc "c" (^TCPConnection),
	getError:                    proc "c" (^TCPConnection) -> PDNetErr,
	setConnectTimeout:           proc "c" (^TCPConnection, i32),
	setUserdata:                 proc "c" (^TCPConnection, rawptr),
	getUserdata:                 proc "c" (^TCPConnection) -> rawptr,
	open:                        proc "c" (^TCPConnection, TCPOpenCallback, rawptr) -> PDNetErr,
	close:                       proc "c" (^TCPConnection) -> PDNetErr,
	setConnectionClosedCallback: proc "c" (^TCPConnection, TCPConnectionCallback),
	setReadTimeout:              proc "c" (^TCPConnection, i32),
	setReadBufferSize:           proc "c" (^TCPConnection, i32),
	size_t:                      proc "c" (^i32) -> proc "c" (^TCPConnection) -> i32,
	read:                        proc "c" (^TCPConnection, rawptr, i32) -> i32, // returns # of bytes read, or PDNetErr on error
	write:                       proc "c" (^TCPConnection, rawptr, i32) -> i32, // returns # of bytes sent, or PDNetErr on error
}

network :: struct {
	http:       ^http,
	tcp:        ^tcp,
	getStatus:  proc "c" () -> WifiStatus,
	setEnabled: proc "c" (i32, proc "c" (PDNetErr)),
	reserved:   [3]i32,
}


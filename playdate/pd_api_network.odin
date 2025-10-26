//
//  pd_api_http.h
//  Playdate Simulator
//
//  Created by Dave Hayden on 7/18/24.
//  Copyright © 2024 Panic, Inc. All rights reserved.
//
package playdate

HTTPConnection :: struct {}
TCPConnection  :: struct {}

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
	NotConnected = 0, //!< Not connected to an AP
	Connected    = 1, //!< Device is connected to an AP
	NotAvailable = 2, //!< A connection has been attempted and no configured AP was available
}

AccessRequestCallback  :: proc "c" (allowed: bool, userdata: rawptr)
HTTPConnectionCallback :: proc "c" (connection: ^HTTPConnection)
HTTPHeaderCallback     :: proc "c" (conn: ^HTTPConnection, key: cstring, value: cstring)

http :: struct {
	requestAccess:               proc "c" (server: cstring, port: i32, usessl: bool, purpose: cstring, requestCallback: AccessRequestCallback, userdata: rawptr) -> accessReply,
	newConnection:               proc "c" (server: cstring, port: i32, usessl: bool) -> ^HTTPConnection,
	retain:                      proc "c" (http: ^HTTPConnection) -> ^HTTPConnection,
	release:                     proc "c" (http: ^HTTPConnection),
	setConnectTimeout:           proc "c" (connection: ^HTTPConnection, ms: i32),
	setKeepAlive:                proc "c" (connection: ^HTTPConnection, keepalive: bool),
	setByteRange:                proc "c" (connection: ^HTTPConnection, start: i32, end: i32),
	setUserdata:                 proc "c" (connection: ^HTTPConnection, userdata: rawptr),
	getUserdata:                 proc "c" (connection: ^HTTPConnection) -> rawptr,
	get:                         proc "c" (conn: ^HTTPConnection, path: cstring, headers: cstring, headerlen: i32) -> PDNetErr,
	post:                        proc "c" (conn: ^HTTPConnection, path: cstring, headers: cstring, headerlen: i32, body: cstring, bodylen: i32) -> PDNetErr,
	query:                       proc "c" (conn: ^HTTPConnection, method: cstring, path: cstring, headers: cstring, headerlen: i32, body: cstring, bodylen: i32) -> PDNetErr,
	getError:                    proc "c" (connection: ^HTTPConnection) -> PDNetErr,
	getProgress:                 proc "c" (conn: ^HTTPConnection, read: ^i32, total: ^i32),
	getResponseStatus:           proc "c" (connection: ^HTTPConnection) -> i32,
	size_t:                      proc "c" (conn: ^HTTPConnection, getBytesAvailable: ^i32) -> proc "c" (connection: ^HTTPConnection) -> i32,
	setReadTimeout:              proc "c" (conn: ^HTTPConnection, ms: i32),
	setReadBufferSize:           proc "c" (conn: ^HTTPConnection, bytes: i32),
	read:                        proc "c" (conn: ^HTTPConnection, buf: rawptr, buflen: u32) -> i32,
	close:                       proc "c" (connection: ^HTTPConnection),
	setHeaderReceivedCallback:   proc "c" (connection: ^HTTPConnection, headercb: HTTPHeaderCallback),
	setHeadersReadCallback:      proc "c" (connection: ^HTTPConnection, callback: HTTPConnectionCallback),
	setResponseCallback:         proc "c" (connection: ^HTTPConnection, callback: HTTPConnectionCallback),
	setRequestCompleteCallback:  proc "c" (connection: ^HTTPConnection, callback: HTTPConnectionCallback),
	setConnectionClosedCallback: proc "c" (connection: ^HTTPConnection, callback: HTTPConnectionCallback),
}

TCPConnectionCallback :: proc "c" (connection: ^TCPConnection, err: PDNetErr)
TCPOpenCallback       :: proc "c" (conn: ^TCPConnection, err: PDNetErr, ud: rawptr)

tcp :: struct {
	requestAccess:               proc "c" (server: cstring, port: i32, usessl: bool, purpose: cstring, requestCallback: AccessRequestCallback, userdata: rawptr) -> accessReply,
	newConnection:               proc "c" (server: cstring, port: i32, usessl: bool) -> ^TCPConnection,
	retain:                      proc "c" (http: ^TCPConnection) -> ^TCPConnection,
	release:                     proc "c" (http: ^TCPConnection),
	getError:                    proc "c" (connection: ^TCPConnection) -> PDNetErr,
	setConnectTimeout:           proc "c" (connection: ^TCPConnection, ms: i32),
	setUserdata:                 proc "c" (connection: ^TCPConnection, userdata: rawptr),
	getUserdata:                 proc "c" (connection: ^TCPConnection) -> rawptr,
	open:                        proc "c" (conn: ^TCPConnection, cb: TCPOpenCallback, ud: rawptr) -> PDNetErr,
	close:                       proc "c" (conn: ^TCPConnection) -> PDNetErr,
	setConnectionClosedCallback: proc "c" (conn: ^TCPConnection, callback: TCPConnectionCallback),
	setReadTimeout:              proc "c" (conn: ^TCPConnection, ms: i32),
	setReadBufferSize:           proc "c" (conn: ^TCPConnection, bytes: i32),
	size_t:                      proc "c" (conn: ^TCPConnection, getBytesAvailable: ^i32) -> proc "c" (^TCPConnection) -> i32,
	read:                        proc "c" (conn: ^TCPConnection, buffer: rawptr, length: i32) -> i32, // returns # of bytes read, or PDNetErr on error
	write:                       proc "c" (conn: ^TCPConnection, buffer: rawptr, length: i32) -> i32, // returns # of bytes sent, or PDNetErr on error
}

network :: struct {
	http:       ^http,
	tcp:        ^tcp,
	getStatus:  proc "c" () -> WifiStatus,
	setEnabled: proc "c" (flag: bool, callback: proc "c" (err: PDNetErr)),
	reserved:   [3]i32,
}


package playdate

import "core:mem"

TEMP_ARENA_SIZE :: #config(PLAYDATE_TEMP_ARENA_SIZE, 64 * 1024)

@(private = "file")
_temp_arena_buf: [TEMP_ARENA_SIZE]u8

@(private = "file")
_temp_arena: mem.Arena

@(require_results)
default_temp_allocator :: proc "contextless" () -> mem.Allocator {
	_temp_arena = mem.Arena {
		data = _temp_arena_buf[:],
	}
	return mem.Allocator{procedure = mem.arena_allocator_proc, data = &_temp_arena}
}

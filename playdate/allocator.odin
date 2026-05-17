package playdate

import "base:runtime"
import mem "core:mem"

@(require_results)
heap_allocator :: proc "contextless" () -> mem.Allocator {
	return mem.Allocator{procedure = heap_allocator_proc, data = cast(rawptr)pd_api.system.realloc}
}

heap_allocator_proc :: proc(
	allocator_data: rawptr,
	mode: mem.Allocator_Mode,
	size, alignment: int,
	old_memory: rawptr,
	old_size: int,
	location := #caller_location,
) -> (
	[]byte,
	mem.Allocator_Error,
) {
	// pd_realloc aligns to 8 bytes on device and 16 on the 64-bit simulator.
	// If hitting this assert - investigate what requested it.
	MAX_ALIGNMENT :: 2 * size_of(rawptr)
	ensure(alignment <= MAX_ALIGNMENT, loc = location)

	PD_Realloc_Proc :: #type proc "c" (_: rawptr, _: i32) -> rawptr
	pd_realloc := cast(PD_Realloc_Proc)allocator_data

	realloc :: proc(
		old_memory: rawptr,
		size, alignment: int,
		pd_realloc: PD_Realloc_Proc,
		location: runtime.Source_Code_Location,
	) -> (
		[]byte,
		mem.Allocator_Error,
	) {
		new_memory := pd_realloc(old_memory, cast(i32)size)
		if new_memory == nil && size != 0 {
			return nil, .Out_Of_Memory
		}
		// Rely on pd_realloc aligning correctly by default.
		ensure(alignment == 0 || uintptr(new_memory) % uintptr(alignment) == 0, loc = location)
		return mem.byte_slice(new_memory, size), nil
	}

	switch mode {
	case .Alloc:
		bytes, err := realloc(nil, size, alignment, pd_realloc, location)
		if err == nil {
			mem.zero_slice(bytes)
		}
		return bytes, err

	case .Alloc_Non_Zeroed:
		return realloc(nil, size, alignment, pd_realloc, location)

	case .Free:
		pd_realloc(old_memory, 0)
		return nil, nil

	case .Free_All:
		return nil, .Mode_Not_Implemented

	case .Resize:
		bytes, err := realloc(old_memory, size, alignment, pd_realloc, location)
		if err == nil && size > old_size {
			mem.zero_slice(bytes[old_size:])
		}
		return bytes, err

	case .Resize_Non_Zeroed:
		return realloc(old_memory, size, alignment, pd_realloc, location)

	case .Query_Features:
		set := (^mem.Allocator_Mode_Set)(old_memory)
		if set != nil {
			set^ = {.Alloc, .Alloc_Non_Zeroed, .Free, .Resize, .Resize_Non_Zeroed, .Query_Features}
		}
		return nil, nil

	case .Query_Info:
		return nil, .Mode_Not_Implemented
	}

	return nil, nil
}

package test

import "core:mem"
import "core:slice"

ALLOCATOR_TESTS :: Test_Suite {
	"Allocator",
	{
		{"alloc_zero_initializes", test_alloc_zero_initializes},
		{"resize_grow_zeroes_new_tail", test_resize_grow_zeroes_new_tail},
		{"resize_shrink_preserves", test_resize_shrink_preserves},
		{"free_then_alloc", test_free_then_alloc},
	},
}

@(private = "file")
test_alloc_zero_initializes :: proc() -> bool {
	data := make([]u8, 256)
	defer delete(data)
	expect_not_nil(data) or_return

	expect(slice.all_of(data, u8(0))) or_return
	return true
}

@(private = "file")
test_resize_grow_zeroes_new_tail :: proc() -> bool {
	OLD :: 64
	NEW :: 256

	data, alloc_err := mem.alloc_bytes(OLD)
	expect_eq(alloc_err, mem.Allocator_Error.None) or_return
	expect_not_nil(data) or_return

	// Dirty the original region so that, if pd_realloc grows in-place and we
	// forget to zero the tail, leftover bytes would be visible.
	mem.set(raw_data(data), 0xAA, len(data))

	grown, resize_err := mem.resize_bytes(data, NEW)
	defer delete(grown)
	expect_eq(resize_err, mem.Allocator_Error.None) or_return
	expect_not_nil(grown) or_return

	expect(slice.all_of(grown[OLD:], u8(0))) or_return
	return true
}

@(private = "file")
test_resize_shrink_preserves :: proc() -> bool {
	OLD :: 256
	NEW :: 64

	data, alloc_err := mem.alloc_bytes(OLD)
	expect_eq(alloc_err, mem.Allocator_Error.None) or_return
	expect_not_nil(data) or_return

	for i in 0 ..< OLD {
		data[i] = u8(i)
	}

	shrunk, resize_err := mem.resize_bytes(data, NEW)
	defer delete(shrunk)
	expect_eq(resize_err, mem.Allocator_Error.None) or_return
	expect_not_nil(shrunk) or_return
	expect_eq(len(shrunk), NEW) or_return

	for i in 0 ..< NEW {
		expect_eq(shrunk[i], u8(i)) or_return
	}
	return true
}

@(private = "file")
test_free_then_alloc :: proc() -> bool {
	a := make([]u8, 128)
	expect_not_nil(a) or_return
	mem.set(raw_data(a), 0x5A, len(a))
	delete(a)

	b, err := mem.alloc_bytes(128)
	defer delete(b)
	expect_eq(err, mem.Allocator_Error.None) or_return
	expect_not_nil(b) or_return
	expect(slice.all_of(b, u8(0))) or_return

	mem.set(raw_data(b), 0xC3, len(b))
	expect_eq(b[0], u8(0xC3)) or_return
	expect_eq(b[len(b) - 1], u8(0xC3)) or_return
	return true
}

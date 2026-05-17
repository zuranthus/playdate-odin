package test

import playdate "../playdate"
import "base:runtime"
import "core:c"
import "core:fmt"

PLATFORM_TESTS :: Test_Suite {
	"Platform",
	{
		{"realloc_alloc", test_realloc_alloc},
		{"realloc_8byte_aligned", test_realloc_8byte_aligned},
		{"realloc_grow_preserves", test_realloc_grow_preserves},
		{"realloc_shrink_preserves", test_realloc_shrink_preserves},
		{"realloc_free_returns_nil", test_realloc_free_returns_nil},
		{"printf_d", test_printf_d},
		{"printf_s", test_printf_s},
		{"printf_precision_s", test_printf_precision_s},
		{"fmt_bprintf", test_fmt_bprintf},
	},
}

@(private = "file")
test_realloc_alloc :: proc() -> bool {
	context.allocator = runtime.panic_allocator()

	p := playdate.system_realloc(nil, 64)
	defer playdate.system_realloc(p, 0)
	expect_not_nil(p) or_return
	return true
}

@(private = "file")
test_realloc_8byte_aligned :: proc() -> bool {
	context.allocator = runtime.panic_allocator()

	sizes := [?]c.size_t{1, 7, 8, 17, 64, 1000}
	for size in sizes {
		p := playdate.system_realloc(nil, size)
		defer playdate.system_realloc(p, 0)
		expect_not_nil(p) or_return
		expect_eq(uintptr(p) & 0b111, uintptr(0)) or_return
	}
	return true
}

@(private = "file")
test_realloc_grow_preserves :: proc() -> bool {
	context.allocator = runtime.panic_allocator()

	p := cast([^]u8)playdate.system_realloc(nil, 16)
	expect_not_nil(p) or_return
	for i in 0 ..< 16 {
		p[i] = u8(i + 1)
	}

	q := cast([^]u8)playdate.system_realloc(p, 64)
	defer playdate.system_realloc(q, 0)
	expect_not_nil(q) or_return
	for i in 0 ..< 16 {
		expect_eq(q[i], u8(i + 1)) or_return
	}
	return true
}

@(private = "file")
test_realloc_shrink_preserves :: proc() -> bool {
	context.allocator = runtime.panic_allocator()

	p := cast([^]u8)playdate.system_realloc(nil, 64)
	expect_not_nil(p) or_return
	for i in 0 ..< 64 {
		p[i] = u8(i + 1)
	}

	q := cast([^]u8)playdate.system_realloc(p, 16)
	defer playdate.system_realloc(q, 0)
	expect_not_nil(q) or_return
	for i in 0 ..< 16 {
		expect_eq(q[i], u8(i + 1)) or_return
	}
	return true
}

@(private = "file")
test_realloc_free_returns_nil :: proc() -> bool {
	context.allocator = runtime.panic_allocator()

	p := playdate.system_realloc(nil, 32)
	expect_not_nil(p) or_return
	q := playdate.system_realloc(p, 0)
	expect_nil(q) or_return
	return true
}

@(private = "file")
test_printf_d :: proc() -> bool {
	context.allocator = runtime.panic_allocator()

	got: cstring
	n := playdate.pd_api.system.formatString(&got, "%d", 42)
	defer playdate.system_realloc(cast(rawptr)got, 0)
	expect_eq(string(got), "42") or_return
	expect_eq(n, 2) or_return
	return true
}

@(private = "file")
test_printf_s :: proc() -> bool {
	context.allocator = runtime.panic_allocator()

	got: cstring
	playdate.pd_api.system.formatString(&got, "[%s]", cstring("hi"))
	defer playdate.system_realloc(cast(rawptr)got, 0)
	expect_eq(string(got), "[hi]") or_return
	return true
}

@(private = "file")
test_fmt_bprintf :: proc() -> bool {
	context.allocator = runtime.panic_allocator()

	buf: [64]u8
	expect_eq(fmt.bprintf(buf[:], "%v", 42), "42") or_return
	expect_eq(fmt.bprintf(buf[:], "%v", u8(0xAB)), "171") or_return
	expect_eq(fmt.bprintf(buf[:], "%v", "hello"), "hello") or_return
	expect_eq(fmt.bprintf(buf[:], "%v", rawptr(uintptr(0x1234))), "0x1234") or_return
	expect_eq(fmt.bprintf(buf[:], "%d/%s", 7, "x"), "7/x") or_return
	return true
}

@(private = "file")
test_printf_precision_s :: proc() -> bool {
	context.allocator = runtime.panic_allocator()

	src := "hello world"
	got: cstring
	n := playdate.pd_api.system.formatString(&got, "%.*s", 5, raw_data(src))
	defer playdate.system_realloc(cast(rawptr)got, 0)
	expect_eq(string(got), "hello") or_return
	expect_eq(n, 5) or_return
	return true
}

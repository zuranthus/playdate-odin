package test

import playdate "../playdate"
import "base:runtime"
import "core:strings"

LOGGER_TESTS :: Test_Suite {
	"Logger",
	{
		{"no_opts_text_only", test_no_opts_text_only},
		{"level_header", test_level_header},
		{"level_header_all_levels", test_level_header_all_levels},
		{"short_file_path_strips_dirs", test_short_file_path_strips_dirs},
		{"long_file_path_keeps_full", test_long_file_path_keeps_full},
		{"line_only", test_line_only},
		{"procedure_only", test_procedure_only},
		{"full_location_header", test_full_location_header},
		{"empty_text_with_header", test_empty_text_with_header},
		{"terminal_color_wraps_level_header", test_terminal_color_wraps_level_header},
		{"terminal_color_per_level", test_terminal_color_per_level},
		{"terminal_color_without_level_opt_is_noop", test_terminal_color_without_level_opt_is_noop},
		{"time_header_date_only", test_time_header_date_only},
		{"time_header_time_only", test_time_header_time_only},
		{"time_header_date_and_time", test_time_header_date_and_time},
		{"time_header_no_opts_is_noop", test_time_header_no_opts_is_noop},
		{"time_header_zero_pads_single_digits", test_time_header_zero_pads_single_digits},
	},
}

@(private = "file")
SAMPLE_DT :: playdate.PD_Date_Time {
	year    = 2026,
	month   = 5,
	day     = 17,
	weekday = 1,
	hour    = 14,
	minute  = 23,
	second  = 9,
}

@(private = "file")
format_time :: proc(buf: []u8, options: runtime.Logger_Options, dt: playdate.PD_Date_Time) -> string {
	sb := strings.builder_from_bytes(buf)
	playdate.format_time_header(&sb, options, dt)
	return strings.to_string(sb)
}

@(private = "file")
SAMPLE_LOC :: runtime.Source_Code_Location {
	file_path = "/a/b/c/foo.odin",
	line      = 42,
	column    = 7,
	procedure = "do_thing",
}

@(private = "file")
test_no_opts_text_only :: proc() -> bool {
	buf: [256]u8
	got := playdate.format_log_message(buf[:], .Info, "hello", {}, SAMPLE_LOC)
	expect_eq(got, "hello") or_return
	return true
}

@(private = "file")
test_level_header :: proc() -> bool {
	buf: [256]u8
	got := playdate.format_log_message(buf[:], .Info, "hi", {.Level}, SAMPLE_LOC)
	expect_eq(got, "[INFO ] --- hi") or_return
	return true
}

@(private = "file")
test_level_header_all_levels :: proc() -> bool {
	buf: [256]u8
	cases := [?]struct {
		level: runtime.Logger_Level,
		want:  string,
	} {
		{.Debug, "[DEBUG] --- x"},
		{.Info, "[INFO ] --- x"},
		{.Warning, "[WARN ] --- x"},
		{.Error, "[ERROR] --- x"},
		{.Fatal, "[FATAL] --- x"},
	}
	for tc in cases {
		got := playdate.format_log_message(buf[:], tc.level, "x", {.Level}, SAMPLE_LOC)
		expect_eq(got, tc.want) or_return
	}
	return true
}

@(private = "file")
test_short_file_path_strips_dirs :: proc() -> bool {
	buf: [256]u8
	got := playdate.format_log_message(buf[:], .Info, "x", {.Short_File_Path}, SAMPLE_LOC)
	expect_eq(got, "[foo.odin] x") or_return
	return true
}

@(private = "file")
test_long_file_path_keeps_full :: proc() -> bool {
	buf: [256]u8
	got := playdate.format_log_message(buf[:], .Info, "x", {.Long_File_Path}, SAMPLE_LOC)
	expect_eq(got, "[/a/b/c/foo.odin] x") or_return
	return true
}

@(private = "file")
test_line_only :: proc() -> bool {
	buf: [256]u8
	got := playdate.format_log_message(buf[:], .Info, "x", {.Line}, SAMPLE_LOC)
	expect_eq(got, "[42] x") or_return
	return true
}

@(private = "file")
test_procedure_only :: proc() -> bool {
	buf: [256]u8
	got := playdate.format_log_message(buf[:], .Info, "x", {.Procedure}, SAMPLE_LOC)
	expect_eq(got, "[do_thing()] x") or_return
	return true
}

@(private = "file")
test_full_location_header :: proc() -> bool {
	buf: [256]u8
	opts := runtime.Logger_Options{.Level, .Short_File_Path, .Line, .Procedure}
	got := playdate.format_log_message(buf[:], .Error, "boom", opts, SAMPLE_LOC)
	expect_eq(got, "[ERROR] --- [foo.odin:42:do_thing()] boom") or_return
	return true
}

@(private = "file")
test_empty_text_with_header :: proc() -> bool {
	buf: [256]u8
	got := playdate.format_log_message(buf[:], .Info, "", {.Level}, SAMPLE_LOC)
	expect_eq(got, "[INFO ] --- ") or_return
	return true
}

@(private = "file")
test_terminal_color_wraps_level_header :: proc() -> bool {
	buf: [256]u8
	got := playdate.format_log_message(buf[:], .Warning, "x", {.Level, .Terminal_Color}, SAMPLE_LOC)
	// Yellow open + header + reset, then text.
	expect_eq(got, "\e[33m[WARN ] --- \e[0mx") or_return
	return true
}

@(private = "file")
test_terminal_color_per_level :: proc() -> bool {
	buf: [256]u8
	cases := [?]struct {
		level: runtime.Logger_Level,
		want:  string,
	} {
		{.Debug, "\e[90m[DEBUG] --- \e[0mx"},
		{.Info, "\e[0m[INFO ] --- \e[0mx"},
		{.Warning, "\e[33m[WARN ] --- \e[0mx"},
		{.Error, "\e[31m[ERROR] --- \e[0mx"},
		{.Fatal, "\e[31m[FATAL] --- \e[0mx"},
	}
	for tc in cases {
		got := playdate.format_log_message(buf[:], tc.level, "x", {.Level, .Terminal_Color}, SAMPLE_LOC)
		expect_eq(got, tc.want) or_return
	}
	return true
}

@(private = "file")
test_terminal_color_without_level_opt_is_noop :: proc() -> bool {
	// .Terminal_Color only colors the level header; with .Level absent, no codes emitted.
	buf: [256]u8
	got := playdate.format_log_message(buf[:], .Error, "x", {.Terminal_Color}, SAMPLE_LOC)
	expect_eq(got, "x") or_return
	return true
}

@(private = "file")
test_time_header_date_only :: proc() -> bool {
	buf: [64]u8
	got := format_time(buf[:], {.Date}, SAMPLE_DT)
	expect_eq(got, "[2026-05-17] ") or_return
	return true
}

@(private = "file")
test_time_header_time_only :: proc() -> bool {
	buf: [64]u8
	got := format_time(buf[:], {.Time}, SAMPLE_DT)
	expect_eq(got, "[14:23:09] ") or_return
	return true
}

@(private = "file")
test_time_header_date_and_time :: proc() -> bool {
	buf: [64]u8
	got := format_time(buf[:], {.Date, .Time}, SAMPLE_DT)
	expect_eq(got, "[2026-05-17 14:23:09] ") or_return
	return true
}

@(private = "file")
test_time_header_no_opts_is_noop :: proc() -> bool {
	// Neither .Date nor .Time set: nothing written, regardless of other opts.
	buf: [64]u8
	got := format_time(buf[:], {.Level, .Short_File_Path}, SAMPLE_DT)
	expect_eq(got, "") or_return
	return true
}

@(private = "file")
test_time_header_zero_pads_single_digits :: proc() -> bool {
	// Month/day/hour/minute/second are zero-padded to two chars. Year is not padded.
	dt := playdate.PD_Date_Time {
		year   = 99,
		month  = 1,
		day    = 2,
		hour   = 3,
		minute = 4,
		second = 5,
	}
	buf: [64]u8
	got := format_time(buf[:], {.Date, .Time}, dt)
	expect_eq(got, "[99-01-02 03:04:05] ") or_return
	return true
}

package test

import playdate "../playdate"
import "base:runtime"

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
	},
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

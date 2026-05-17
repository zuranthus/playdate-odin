package playdate

import "base:runtime"
import "core:c"
import "core:fmt"
import "core:strings"
import "core:terminal/ansi"

// This logger does not honor .Thread_Id.
DEFAULT_LOGGER_OPTS :: runtime.Logger_Options{.Level, .Date, .Time, .Short_File_Path, .Line, .Procedure}

@(private = "file")
LEVEL_HEADERS := [?]string {
	0 ..< 10 = "[DEBUG] --- ",
	10 ..< 20 = "[INFO ] --- ",
	20 ..< 30 = "[WARN ] --- ",
	30 ..< 40 = "[ERROR] --- ",
	40 ..< 50 = "[FATAL] --- ",
}

@(private = "file")
RESET :: ansi.CSI + ansi.RESET + ansi.SGR

@(private = "file")
LEVEL_COLORS := [?]string {
	0 ..< 10 = ansi.CSI + ansi.FG_BRIGHT_BLACK + ansi.SGR,
	10 ..< 20 = ansi.CSI + ansi.RESET + ansi.SGR,
	20 ..< 30 = ansi.CSI + ansi.FG_YELLOW + ansi.SGR,
	30 ..< 40 = ansi.CSI + ansi.FG_RED + ansi.SGR,
	40 ..< 50 = ansi.CSI + ansi.FG_RED + ansi.SGR,
}

@(private = "file")
TIMESTAMP_OPTS :: runtime.Logger_Options{.Date, .Time}

@(private = "file")
LOCATION_HEADER_OPTS :: runtime.Logger_Options{.Short_File_Path, .Long_File_Path, .Line, .Procedure}

@(private = "file")
LOCATION_FILE_OPTS :: runtime.Logger_Options{.Short_File_Path, .Long_File_Path}

// `loc` is captured to detect whether the binary was built with source-code
// locations stripped (`-source-code-locations:none`).
@(require_results)
console_logger :: proc "contextless" (
	lowest := runtime.Logger_Level.Debug,
	opt := DEFAULT_LOGGER_OPTS,
	loc := #caller_location,
) -> runtime.Logger {
	effective_opts := opt
	if loc.file_path == "" {
		// Strip location headers if the binary was built without source code locations.
		effective_opts &~= LOCATION_HEADER_OPTS
	}
	return runtime.Logger{console_logger_proc, nil, lowest, effective_opts}
}

@(private = "file")
console_logger_proc :: proc(
	logger_data: rawptr,
	level: runtime.Logger_Level,
	text: string,
	options: runtime.Logger_Options,
	location := #caller_location,
) {
	buf: [1024]u8
	msg := format_log_message(buf[:], level, text, options, location)
	if level >= .Fatal {
		pd_api.system.error("%.*s", c.int(len(msg)), raw_data(msg))
	} else {
		pd_api.system.logToConsole("%.*s", c.int(len(msg)), raw_data(msg))
	}
}

@(require_results)
format_log_message :: proc(
	buf: []u8,
	level: runtime.Logger_Level,
	text: string,
	options: runtime.Logger_Options,
	location: runtime.Source_Code_Location,
) -> string {
	sb := strings.builder_from_bytes(buf)

	if .Level in options {
		if .Terminal_Color in options {
			strings.write_string(&sb, LEVEL_COLORS[level])
		}
		strings.write_string(&sb, LEVEL_HEADERS[level])
		if .Terminal_Color in options {
			strings.write_string(&sb, RESET)
		}
	}

	write_time_header(&sb, options)
	write_location_header(&sb, options, location)

	strings.write_string(&sb, text)
	return strings.to_string(sb)
}

@(private = "file")
write_time_header :: proc(sb: ^strings.Builder, options: runtime.Logger_Options) {
	if TIMESTAMP_OPTS & options == nil {
		return
	}
	ms: u32
	epoch := system_get_seconds_since_epoch(&ms)
	dt: PD_Date_Time
	system_convert_epoch_to_date_time(epoch, &dt)
	format_time_header(sb, options, dt)
}

format_time_header :: proc(sb: ^strings.Builder, options: runtime.Logger_Options, dt: PD_Date_Time) {
	if TIMESTAMP_OPTS & options == nil {
		return
	}
	strings.write_byte(sb, '[')
	if .Date in options {
		fmt.sbprintf(sb, "%d-%02d-%02d", dt.year, dt.month, dt.day)
		if .Time in options {
			strings.write_byte(sb, ' ')
		}
	}
	if .Time in options {
		fmt.sbprintf(sb, "%02d:%02d:%02d", dt.hour, dt.minute, dt.second)
	}
	strings.write_string(sb, "] ")
}

@(private = "file")
write_location_header :: proc(
	sb: ^strings.Builder,
	options: runtime.Logger_Options,
	location: runtime.Source_Code_Location,
) {
	if LOCATION_HEADER_OPTS & options == nil {
		return
	}

	strings.write_byte(sb, '[')

	file := location.file_path
	if .Short_File_Path in options {
		last := 0
		for r, i in location.file_path {
			if r == '/' {
				last = i + 1
			}
		}
		file = location.file_path[last:]
	}

	if LOCATION_FILE_OPTS & options != nil {
		strings.write_string(sb, file)
	}
	if .Line in options {
		if LOCATION_FILE_OPTS & options != nil {
			strings.write_byte(sb, ':')
		}
		fmt.sbprintf(sb, "%d", location.line)
	}
	if .Procedure in options {
		if (LOCATION_FILE_OPTS | {.Line}) & options != nil {
			strings.write_byte(sb, ':')
		}
		fmt.sbprintf(sb, "%s()", location.procedure)
	}

	strings.write_string(sb, "] ")
}

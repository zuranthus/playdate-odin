package test

import playdate "../playdate"
import "core:c"
import "core:fmt"

TEST_FILTER :: #config(TEST_FILTER, "")

Test_Func :: #type proc() -> bool

Test_Entry :: struct {
	name: string,
	func: Test_Func,
}

Test_Suite :: struct {
	name:  string,
	tests: []Test_Entry,
}

expect :: proc(ok: bool, loc := #caller_location, expr := #caller_expression(ok)) -> bool {
	if !ok {
		report_failure("  %s(%d) expect(%s) failed: %v", loc.file_path, loc.line, expr, ok)
	}
	return ok
}

expect_eq :: proc(
	a, b: $V,
	loc := #caller_location,
	a_expr := #caller_expression(a),
	b_expr := #caller_expression(b),
) -> bool {
	ok := a == b
	if !ok {
		report_failure("  %s(%d) expect_eq(%s, %s) failed: %v, %v", loc.file_path, loc.line, a_expr, b_expr, a, b)
	}
	return ok
}

expect_ne :: proc(
	a, b: $V,
	loc := #caller_location,
	a_expr := #caller_expression(a),
	b_expr := #caller_expression(b),
) -> bool {
	ok := a != b
	if !ok {
		report_failure("  %s(%d) expect_ne(%s, %s) failed: %v, %v", loc.file_path, loc.line, a_expr, b_expr, a, b)
	}
	return ok
}

expect_nil :: proc(val: $V, loc := #caller_location, expr := #caller_expression(val)) -> bool {
	ok := val == nil
	if !ok {
		report_failure("  %s(%d) expect_nil(%s) failed: %v", loc.file_path, loc.line, expr, val)
	}
	return ok
}

expect_not_nil :: proc(val: $V, loc := #caller_location, expr := #caller_expression(val)) -> bool {
	ok := val != nil
	if !ok {
		report_failure("  %s(%d) expect_not_nil(%s) failed: %v", loc.file_path, loc.line, expr, val)
	}
	return ok
}

run_test_suites :: proc(suites: []Test_Suite) {
	pd := playdate.pd_api
	total_passed, total_failed, total_skipped: int
	run_started := playdate.system_get_current_time_milliseconds()

	for suite in suites {
		pd.system.logToConsole("=== %.*s ===", c.int(len(suite.name)), raw_data(suite.name))

		for entry in suite.tests {
			if !matches_filter(suite.name, entry.name) {
				pd.system.logToConsole(
					"[SKIP] %.*s.%.*s",
					c.int(len(suite.name)),
					raw_data(suite.name),
					c.int(len(entry.name)),
					raw_data(entry.name),
				)
				total_skipped += 1
				continue
			}

			test_failed = false
			pd.system.logToConsole(
				"[RUN]  %.*s.%.*s",
				c.int(len(suite.name)),
				raw_data(suite.name),
				c.int(len(entry.name)),
				raw_data(entry.name),
			)
			start := playdate.system_get_current_time_milliseconds()
			_ = entry.func()
			elapsed := playdate.system_get_current_time_milliseconds() - start

			if test_failed {
				pd.system.logToConsole(
					"[FAIL] %.*s.%.*s (%dms)",
					c.int(len(suite.name)),
					raw_data(suite.name),
					c.int(len(entry.name)),
					raw_data(entry.name),
					elapsed,
				)
				total_failed += 1
			} else {
				pd.system.logToConsole(
					"[PASS] %.*s.%.*s (%dms)",
					c.int(len(suite.name)),
					raw_data(suite.name),
					c.int(len(entry.name)),
					raw_data(entry.name),
					elapsed,
				)
				total_passed += 1
			}
		}
	}

	total_ms := playdate.system_get_current_time_milliseconds() - run_started
	pd.system.logToConsole("")
	pd.system.logToConsole(
		"=== Results: %d passed, %d failed, %d skipped (%dms) ===",
		total_passed,
		total_failed,
		total_skipped,
		total_ms,
	)
	pd.system.logToConsole("=== DONE ===")
}

@(private = "file")
test_failed: bool

@(private = "file")
matches_filter :: proc(suite_name, test_name: string) -> bool {
	when TEST_FILTER == "" {
		return true
	} else {
		return strings.contains(suite_name, TEST_FILTER) || strings.contains(test_name, TEST_FILTER)
	}
}

@(private = "file")
report_failure :: proc(format: string, args: ..any) {
	test_failed = true
	buf: [512]u8
	msg := fmt.bprintf(buf[:], format, ..args)
	playdate.pd_api.system.logToConsole("%.*s", c.int(len(msg)), raw_data(msg))
}

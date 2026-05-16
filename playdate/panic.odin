package playdate

import "base:runtime"
import "core:c"

panic_contextless :: proc "contextless" (pd: ^API, message: string, loc := #caller_location) -> ! {
	pd.system.error(
		"panic: %.*s at %.*s(%d:%d)",
		c.int(len(message)),
		raw_data(message),
		c.int(len(loc.file_path)),
		raw_data(loc.file_path),
		c.int(loc.line),
		c.int(loc.column),
	)
	runtime.trap()
}

ensure_contextless :: proc "contextless" (
	pd: ^API,
	condition: bool,
	message := #caller_expression(condition),
	loc := #caller_location,
) {
	if !condition {
		panic_contextless(pd, message, loc)
	}
}

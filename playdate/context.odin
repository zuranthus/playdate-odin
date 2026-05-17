package playdate

import "base:runtime"
import "core:c"
import "core:fmt"

@(private = "file")
_default_context: runtime.Context

pd_api: ^API

init_default_context :: proc "contextless" (pd: ^API) {
	ensure_contextless(pd, pd_api == nil, "default_context already initialized")
	pd_api = pd
	_default_context = {
		allocator              = heap_allocator(),
		temp_allocator         = default_temp_allocator(),
		logger                 = console_logger(),
		random_generator       = default_random_generator(),
		assertion_failure_proc = assertion_failure_proc,
	}
}

default_context :: proc "contextless" () -> runtime.Context {
	return _default_context
}

assertion_failure_proc :: proc(prefix, message: string, loc: runtime.Source_Code_Location) -> ! {
	buf: [512]u8
	msg := fmt.bprintf(buf[:], "%s: %s at %s(%d:%d)", prefix, message, loc.file_path, loc.line, loc.column)
	pd_api.system.error("%.*s", c.int(len(msg)), raw_data(msg))
	runtime.trap()
}

package playdate

import "base:runtime"
import "core:c"
import "core:fmt"

@(private = "file")
_default_context: runtime.Context

init_default_context :: proc "contextless" (pd: ^API) {
	ensure_contextless(pd, _default_context.user_ptr == nil, "default_context already initialized")
	_default_context = {
		allocator              = heap_allocator(pd),
		temp_allocator         = default_temp_allocator(),
		logger                 = console_logger(pd),
		assertion_failure_proc = assertion_failure_proc,
		user_ptr               = pd,
	}
}

default_context :: proc "contextless" () -> runtime.Context {
	return _default_context
}

assertion_failure_proc :: proc(prefix, message: string, loc: runtime.Source_Code_Location) -> ! {
	pd := cast(^API)context.user_ptr
	buf: [512]u8
	msg := fmt.bprintf(buf[:], "%s: %s at %s(%d:%d)", prefix, message, loc.file_path, loc.line, loc.column)
	pd.system.error("%.*s", c.int(len(msg)), raw_data(msg))
	runtime.trap()
}

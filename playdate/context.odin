package playdate

import "base:runtime"
import "core:c"
import "core:fmt"

default_context :: proc "contextless" (pd: ^API) -> runtime.Context {
	return {allocator = heap_allocator(pd), assertion_failure_proc = assertion_failure_proc, user_ptr = pd}
}

assertion_failure_proc :: proc(prefix, message: string, loc: runtime.Source_Code_Location) -> ! {
	pd := cast(^API)context.user_ptr
	buf: [512]u8
	msg := fmt.bprintf(buf[:], "%s: %s at %s(%d:%d)", prefix, message, loc.file_path, loc.line, loc.column)
	pd.system.error("%.*s", c.int(len(msg)), raw_data(msg))
	runtime.trap()
}

package trace

import "base:runtime"
import "core:fmt"
import "core:reflect"
import "core:strings"


trace :: proc(value: $T, allocator := context.allocator) -> string {
	context.allocator = allocator

	next, name := get_union_name_and_next_variant(value)
	names := make([dynamic]string)
	append(&names, name)

	for next != nil {
		next, name = get_union_name_and_next_variant(next)
		if name != "" {
			append(&names, name)
		}
	}
	append(&names, fmt.aprintf("%w", value))

	trace := strings.join(names[:], " -> ")

	for name in names {
		delete(name)
	}
	delete(names)
	return trace
}

@(private)
get_union_name_and_next_variant :: proc(a: any, allocator := context.allocator) -> (any, string) {
	context.allocator = allocator

	res := fmt.aprintf("%T", a)
	ti := runtime.type_info_base(type_info_of(a.id))
	_, ok := ti.variant.(runtime.Type_Info_Union)
	if !ok {
		delete(res)
		return nil, ""
	}
	id := reflect.union_variant_typeid(a)
	return any{a.data, id}, res
}

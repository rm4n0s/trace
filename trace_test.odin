package trace

import "core:testing"


@(private = "file")
Another_Error :: enum {
	None,
	Another_Error,
}

@(private = "file")
Example1_Error :: enum {
	None,
	Some_Error,
}

@(private = "file")
Struct_Error :: struct {
	msg: string,
	num: int,
}

@(private = "file")
Example2_Error :: union {
	Example1_Error,
	Another_Error,
	Struct_Error,
}

@(private = "file")
Example3_Error :: union {
	Example2_Error,
	Another_Error,
}

@(private = "file")
Example4_Error :: union {
	Example3_Error,
	Another_Error,
}


@(test)
test_trace :: proc(t: ^testing.T) {
	err_enum := Example4_Error(Example3_Error(Example2_Error(Example1_Error.Some_Error)))
	err_struct := Example4_Error(
		Example3_Error(Example2_Error(Struct_Error{num = 23, msg = "alalalala"})),
	)

	traced_enum := trace(err_enum)
	defer delete(traced_enum)
	traced_struct := trace(err_struct)
	defer delete(traced_struct)

	testing.expect_value(
		t,
		traced_enum,
		"Example4_Error -> Example3_Error -> Example2_Error -> Example1_Error.Some_Error",
	)

	testing.expect_value(
		t,
		traced_struct,
		`Example4_Error -> Example3_Error -> Example2_Error -> Struct_Error{msg = "alalalala", num = 23}`,
	)


}

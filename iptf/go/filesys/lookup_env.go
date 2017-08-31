package filesys

/*
#include <stdlib.h>
*/
import "C"
import (
	"unsafe"
)

// LookupEnv uses the C API to look up an environment variable. We can
// use this as a simple coordination mechanism between, for example,
// a Python test that's loading this as an extension and the (apparently
// asynchronous) Go module initialization process. Ugh, what a hack.
func LookupEnv(key string) (string, bool) {
	keyc := C.CString(key)
	defer C.free(unsafe.Pointer(keyc))
	v := C.getenv(keyc)
	if uintptr(unsafe.Pointer(v)) == 0 {
		return "", false
	}

	return C.GoString(v), true
}

package filesys

// #include <stdlib.h>
import "C"

import (
	"reflect"
	"unsafe"
)

// HeapSlice is part of our unfortunate hack to implement a non-mmap version
//of tensorflow::FileSystem::NewReadOnlyMemoryRegionFromFile(...)
type HeapSlice struct {
	slice         []byte
	unsafePointer unsafe.Pointer
	ptr           uintptr
}

// Returns a []byte of the given length allocated on the C heap. It is the
// caller's responsibility to free the underlying bytes.
func NewHeapSlice(length int) *HeapSlice {
	ptr := C.malloc(C.size_t(length))
	return &HeapSlice{(*[1 << 30]byte)(ptr)[:length], ptr, reflect.ValueOf(ptr).Pointer()}
}

func (p *HeapSlice) Slice() []byte {
	if p.unsafePointer == nil {
		panic("HeapSlice pointer already freed")
	}

	return p.slice
}

func (p *HeapSlice) Free() {
	if p.unsafePointer == nil {
		panic("HeapSlice pointer already freed")
	}

	C.free(p.unsafePointer)
	p.ptr = 0
	p.unsafePointer = nil
}

func (p *HeapSlice) Pointer() uintptr {
	if p.unsafePointer == nil {
		panic("HeapSlice pointer already freed")
	}

	return p.ptr
}

func (p *HeapSlice) Length() int {
	if p.unsafePointer == nil {
		panic("HeapSlice pointer already freed")
	}

	return len(p.slice)
}

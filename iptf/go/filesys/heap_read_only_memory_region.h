#ifndef SWIG_tfi_heap_read_only_memory_region_WRAP_H_
#define SWIG_tfi_heap_read_only_memory_region_WRAP_H_

#include "tensorflow/core/platform/file_system.h"

namespace iptf {

// tensorflow::ReadOnlyMemoryRegion is the TensorFlow API for wrapping mmap-like
// functionality. We haven't yet figured out how to support this from the Go
// side. For now we have a simple fully-allocated heap-based implementation to
// use as a fallback. This is considered a workaround that we'd prefer to
// replace with something much better.
class HeapReadOnlyMemoryRegion : public tensorflow::ReadOnlyMemoryRegion {
 public:
  HeapReadOnlyMemoryRegion(void* data, tensorflow::uint64 length) : _data(data), _length(length) {}
  ~HeapReadOnlyMemoryRegion() {
    free(_data);
  }

  /// \brief Returns a pointer to the memory region.
  const void* data() override {
    return _data;
  }

  /// \brief Returns the length of the memory region in bytes.
  tensorflow::uint64 length() override {
    return _length;
  }

  tensorflow::ReadOnlyMemoryRegion* AsReadOnlyMemoryRegion() {
    return static_cast<tensorflow::ReadOnlyMemoryRegion*>(this);
  }

 private:
  void* _data;
  tensorflow::uint64 _length;
};

};

#endif

The C API for IPTF is very small.

NOTE There is no shutdown or cleanup logic for either of these entry points,
aside from what happens automatically when the process exits and during normal
file system operations.

//iptf/go/c_api:libipfs_internal.so

For C++ tests, we have NewIpfsFileSystem(...). Configuration of the file system
is done via arguments to this function. This function can be called multiple
times in a single process. The instance returned is a subclass of
tensorflow::FileSystem. The actual file system functionality is implemented
in Go and bridged via SWIG's director feature.


//iptf/go/c_api:libipfs.so

For the Python package (and end-to-end tests), we have a module initializer
that runs upon dlopen of our .so. Configuration of the file system is done
via environment variables with the IPTF_ prefix. Because of the way this
part of the API is triggered, it can only be used once per process.

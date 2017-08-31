// Adapted from tensorflow/core/platform/file_system.h
package api

import (
	"io"
)

type Stat struct {
	// True if the file is a directory, otherwise false.
	IsDirectory bool

	// The length of the file or -1 if finding file length is not supported.
	Size int64
}

// WritableFile is a file abstraction for sequential writing.
//
// The implementation must provide buffering since callers may append
// small fragments at a time to the file.
type WritableFile interface {
	// To append 'data' to the file.
	io.Writer

	// Close the file.
	//
	// Flush() and de-allocate resources associated with this file
	//
	// Returns an error if Flush() does.
	io.Closer

	// Syncs contents of file to filesystem.
	//
	// This waits for confirmation from the filesystem that the contents
	// of the file have been persisted to the filesystem; if the OS
	// or machine crashes after a successful Sync, the contents should
	// be properly saved.
	Sync() error

	// Flushes the file and optionally syncs contents to filesystem.
	//
	// This should flush any local buffers whose contents have not been
	// delivered to the filesystem.
	//
	// If the process terminates after a successful flush, the contents
	// may still be persisted, since the underlying filesystem may
	// eventually flush the contents.  If the OS or machine crashes
	// after a successful flush, the contents may or may not be
	// persisted, depending on the implementation.
	Flush() error
}

type ReadOnlyMemoryRegionFactory func(length int, read func([]byte) (int, error)) error

type FileSystem interface {
	// FileExists returns OK if the named path exists and os.ErrNotExist otherwise.
	FileExists(fname string) error

	// GetFileSize returns the size of `fname`, or an error.
	GetFileSize(fname string) (uint64, error)

	// RenameFile overwrites the target if it exists.
	RenameFile(src string, dst string) error

	// DeleteFile deletes the named file.
	DeleteFile(fname string) error

	// CreateDir creates the specified directory. Returns:
	//  * nil - on success.
	//  * os.ErrExist - directory with name dirname already exists.
	//  * os.ErrPermission - dirname is not writable.
	CreateDir(dirname string) error

	// DeleteDir deletes the specified directory.
	DeleteDir(dirname string) error

	// EachChildName calls visit with the immediate children in the given directory.
	// The returned paths are relative to 'dir'.
	EachChildName(dir string, visit func(name string) error) error

	// Stat obtains statistics for the given path.
	Stat(fname string) (*Stat, error)

	// NewReadOnlyMemoryRegionFromFile creates a read-only region of memory with
	// the file context.
	//
	// tensorflow::ReadOnlyMemoryRegion is a readonly (ideally) memmapped file
	// abstraction. We do not have an implementation that actually uses mmap.
	//
	// The implementation must guarantee that all memory is accessible when the
	// object exists, independently from the Env that created it.
	//
	// To achieve the above, we eager load the entire contents of the file into
	// a slice allocated.
	//
	// On success, it calls factory with the length of the file content and
	// a function that will read file contents to a given []byte. This []byte
	// MUST NOT BE USED FOR ANYTHING ELSE, as it is allocated outside of Go's
	// memory management system.
	NewReadOnlyMemoryRegionFromFile(fname string, factory ReadOnlyMemoryRegionFactory) error

	// NewRandomAccessFile creates a brand new random access read-only file with the
	// specified name.
	//
	// The returned io.ReaderAt may be concurrently accessed by multiple threads.
	//
	// The []byte passed to ReadAt MUST NOT BE USED FOR ANYTHING ELSE, as it is
	// allocated outside of Go's memory management system.
	//
	// Safe for concurrent use by multiple threads.
	NewRandomAccessFile(fname string) (io.ReaderAt, error)

	// NewWritableFile returns a WritableFile that writes to a new file with the specified
	// name.
	//
	// Deletes any existing file with the same name and creates a
	// new file.
	//
	// The returned file will only be accessed by one thread at a time.
	NewWritableFile(fname string) (WritableFile, error)

	// NewAppendableFile returns a WritableFile that either appends to an existing file, or
	// writes to a new file (if the file does not exist to begin with).
	//
	// The returned file will only be accessed by one thread at a time.
	NewAppendableFile(fname string) (WritableFile, error)
}

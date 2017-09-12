package filesys_wrap

import (
	"errors"
	"fmt"
	"io"
	"os"

	api "github.com/ajbouh/iptf/go/api"
	tfs "github.com/ajbouh/iptf/go/filesys"
)

func errorAsStatus(context string, err error) tfs.Status {
	switch err {
	case nil:
		return tfs.StatusOK()
	case os.ErrNotExist:
		return tfs.StatusErrorNotFound(context)
	case os.ErrExist:
		return tfs.StatusErrorAlreadyExists(context)
	case os.ErrPermission:
		return tfs.StatusErrorPermissionDenied(context)
	case io.EOF:
		return tfs.StatusErrorOutOfRange(context)
	default:
		fmt.Printf("errorAsStatus %#v %s\n", err, err.Error())
		return tfs.StatusErrorInternal(context + "; " + err.Error())
	}
}

type goFileSystem struct {
	p tfs.FileSystem
	g api.FileSystem
}

func NewFileSystem(g api.FileSystem) *goFileSystem {
	om := &goFileSystem{}
	p := tfs.NewDirectorFileSystem(om)
	om.p = p
	om.g = g
	return om
}

func (p *goFileSystem) DirectorFileSystem() tfs.FileSystem {
	return p.p
}

// Returns OK if the named path exists and NOT_FOUND otherwise.
func (p *goFileSystem) FileExists(fname string) tfs.Status {
	return errorAsStatus(fname, p.g.FileExists(fname))
}

// Stores the size of `fname` in `*file_size`.
func (p *goFileSystem) GetFileSize(fname string, file_size *uint64) tfs.Status {
	size, err := p.g.GetFileSize(fname)
	*file_size = size
	return errorAsStatus(fname, err)
}

// Overwrites the target if it exists.
func (p *goFileSystem) RenameFile(src string, dst string) tfs.Status {
	err := p.g.RenameFile(src, dst)
	// Small hack to avoid doing string concatenation when there's no error.
	if err != nil {
		return errorAsStatus(src+" -> "+dst, err)
	}

	return errorAsStatus("", err)
}

// Deletes the named file.
func (p *goFileSystem) DeleteFile(fname string) tfs.Status {
	return errorAsStatus(fname, p.g.DeleteFile(fname))
}

// Creates the specified directory.
// Typical return codes:
//  * OK - successfully created the directory.
//  * ALREADY_EXISTS - directory with name dirname already exists.
//  * PERMISSION_DENIED - dirname is not writable.
func (p *goFileSystem) CreateDir(dirname string) tfs.Status {
	return errorAsStatus(dirname, p.g.CreateDir(dirname))
}

// Deletes the specified directory.
func (p *goFileSystem) DeleteDir(dirname string) tfs.Status {
	return errorAsStatus(dirname, p.g.DeleteDir(dirname))
}

// Returns the immediate children in the given directory.
//
// The returned paths are relative to 'dir'.
func (p *goFileSystem) GetChildren(dir string, result tfs.StringVector) tfs.Status {
	result.Clear()
	err := p.g.EachChildName(dir, func(name string) error { result.Add(name); return nil })
	return errorAsStatus(dir, err)
}

// Obtains statistics for the given path.
func (p *goFileSystem) Stat(fname string, stat tfs.FileStatistics) tfs.Status {
	s, err := p.g.Stat(fname)
	if err != nil {
		return errorAsStatus(fname, err)
	}

	stat.SetIs_directory(s.IsDirectory)
	stat.SetMtime_nsec(-1)
	stat.SetLength(s.Size)

	return errorAsStatus(fname, err)
}

// Creates a readonly region of memory with the file context.
//
// On success, it returns a pointer to read-only memory region
// from the content of file fname. The ownership of the region is passed to
// the caller. On failure stores nullptr in *result and returns non-OK.
//
// The returned memory region can be accessed from many threads in parallel.
//
// The ownership of the returned ReadOnlyMemoryRegion is passed to the caller
// and the object should be deleted when is not used.
func (p *goFileSystem) NewReadOnlyMemoryRegionFromFile(fname string, result tfs.UniquePointerReadOnlyMemoryRegion) tfs.Status {
	var hs *tfs.HeapSlice
	factory := func(length int, r func([]byte) (int, error)) error {
		if hs != nil {
			return errors.New("Illegal to call factory more than once")
		}

		hs = tfs.NewHeapSlice(length)
		_, err := r(hs.Slice())
		if err != nil {
			hs.Free()
			return err
		}

		return nil
	}

	err := p.g.NewReadOnlyMemoryRegionFromFile(fname, factory)
	if err != nil {
		return errorAsStatus(fname, err)
	}

	if hs != nil {
		hromr := tfs.NewHeapReadOnlyMemoryRegion(hs.Pointer(), uint64(hs.Length()))
		result.Reset(hromr.AsReadOnlyMemoryRegion())
	} else {
		err = errors.New("Failed to populate ReadOnlyMemoryRegion")
	}

	return errorAsStatus(fname, err)
}

type randomAccessFile struct {
	p        tfs.RandomAccessFile
	filename string
	x        io.ReaderAt
}

func (p *randomAccessFile) Read(offset uint64, scratch *[]byte) tfs.Status {
	actual, err := p.x.ReadAt(*scratch, int64(offset))
	if actual < 0 {
		return tfs.StatusErrorOutOfRange(fmt.Sprintf("Offset was past end of file by %d", -actual))
	}

	if actual < len(*scratch) {
		fmt.Printf("will resize slice of len %d to %d", len(*scratch), actual)
		*scratch = (*scratch)[:actual]
	}

	return errorAsStatus(p.filename, err)
}

func (p *goFileSystem) NewRandomAccessFile(fname string, result tfs.UniquePointerRandomAccessFile) tfs.Status {
	raf, err := p.g.NewRandomAccessFile(fname)
	if err != nil {
		return errorAsStatus(fname, err)
	}

	om := &randomAccessFile{}
	om.p = tfs.NewDirectorRandomAccessFile(om)
	om.x = raf
	om.filename = fname
	result.Reset(om.p)

	return errorAsStatus(fname, nil)
}

type writableFile struct {
	p        tfs.WritableFile
	filename string
	of       api.WritableFile
}

func (p *writableFile) Append(data []byte) tfs.Status {
	_, err := p.of.Write(data)
	return errorAsStatus(p.filename, err)
}

func (p *writableFile) Close() tfs.Status {
	return errorAsStatus(p.filename, p.of.Close())
}

func (p *writableFile) Flush() tfs.Status {
	return errorAsStatus(p.filename, p.of.Flush())
}

func (p *writableFile) Sync() tfs.Status {
	return errorAsStatus(p.filename, p.of.Sync())
}

// Creates an object that writes to a new file with the specified
// name.
//
// Deletes any existing file with the same name and creates a
// new file.  On success, stores a pointer to the new file in
// *result and returns OK.  On failure stores NULL in *result and
// returns non-OK.
//
// The returned file will only be accessed by one thread at a time.
//
// The ownership of the returned WritableFile is passed to the caller
// and the object should be deleted when is not used.
func (p *goFileSystem) NewWritableFile(fname string, result tfs.UniquePointerWritableFile) tfs.Status {
	fmt.Printf("NewWritableFile: %s\n", fname)
	of, err := p.g.NewWritableFile(fname)
	if err != nil {
		return errorAsStatus(fname, err)
	}

	om := &writableFile{}
	om.p = tfs.NewDirectorWritableFile(om)
	om.of = of
	result.Reset(om.p)

	return errorAsStatus(fname, err)
}

// Creates an object that either appends to an existing file, or
// writes to a new file (if the file does not exist to begin with).
//
// On success, stores a pointer to the new file in *result and
// returns OK.  On failure stores NULL in *result and returns
// non-OK.
//
// The returned file will only be accessed by one thread at a time.
//
// The ownership of the returned WritableFile is passed to the caller
// and the object should be deleted when is not used.
func (p *goFileSystem) NewAppendableFile(fname string, result tfs.UniquePointerWritableFile) tfs.Status {
	of, err := p.g.NewAppendableFile(fname)
	if err != nil {
		return errorAsStatus(fname, err)
	}

	om := &writableFile{}
	om.filename = fname
	om.p = tfs.NewDirectorWritableFile(om)
	om.of = of
	result.Reset(om.p)

	return errorAsStatus(fname, err)
}

package meta

import (
	"io"

	api "github.com/ajbouh/iptf/go/api"
)

type child interface {
	NewWritableFile() (api.WritableFile, error)
	NewAppendableFile() (api.WritableFile, error)
	Exists() error
	EachChildName(func(string) error) error
	GetFileSize() (uint64, error)
	Stat() (*api.Stat, error)
	NewReadOnlyMemoryRegionFromFile(api.ReadOnlyMemoryRegionFactory) error
	NewRandomAccessFile() (io.ReaderAt, error)
}

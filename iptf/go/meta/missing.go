package meta

import (
	"io"
	"os"

	api "github.com/ajbouh/iptf/go/api"
)

type missingNode struct{}

func (p *missingNode) NewWritableFile() (api.WritableFile, error) {
	return nil, os.ErrPermission
}

func (p *missingNode) NewAppendableFile() (api.WritableFile, error) {
	return nil, os.ErrPermission
}

func (p *missingNode) Exists() error {
	return os.ErrNotExist
}

func (p *missingNode) EachChildName(func(string) error) error {
	return os.ErrNotExist
}

func (p *missingNode) GetFileSize() (uint64, error) {
	return 0, os.ErrNotExist
}

func (p *missingNode) Stat() (*api.Stat, error) {
	return nil, os.ErrNotExist
}

func (p *missingNode) NewReadOnlyMemoryRegionFromFile(api.ReadOnlyMemoryRegionFactory) error {
	return os.ErrNotExist
}

func (p *missingNode) NewRandomAccessFile() (io.ReaderAt, error) {
	return nil, os.ErrNotExist
}

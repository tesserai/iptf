package meta

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"strings"

	rw "github.com/ajbouh/iptf/go/rw"

	api "github.com/ajbouh/iptf/go/api"
)

type metaFileSystem struct {
	mfs *rw.MfsFileSystem
}

func NewMetaFileSystem(mfs *rw.MfsFileSystem) api.FileSystem {
	return &metaFileSystem{
		mfs: mfs,
	}
}

func (p *metaFileSystem) RenameFile(src string, dst string) error {
	return os.ErrPermission
}

func (p *metaFileSystem) DeleteFile(fname string) error {
	return os.ErrPermission
}

func (p *metaFileSystem) CreateDir(dirname string) error {
	return os.ErrPermission
}

func (p *metaFileSystem) DeleteDir(dirname string) error {
	return os.ErrPermission
}

func (p *metaFileSystem) NewWritableFile(fname string) (api.WritableFile, error) {
	return p.resolveChild(fname).NewWritableFile()
}

func (p *metaFileSystem) NewAppendableFile(fname string) (api.WritableFile, error) {
	return p.resolveChild(fname).NewAppendableFile()
}

func (p *metaFileSystem) FileExists(fname string) error {
	return p.resolveChild(fname).Exists()
}

func (p *metaFileSystem) GetFileSize(fname string) (uint64, error) {
	return p.resolveChild(fname).GetFileSize()
}

func (p *metaFileSystem) EachChildName(dirname string, visit func(string) error) error {
	return p.resolveChild(dirname).EachChildName(visit)
}

func (p *metaFileSystem) Stat(fname string) (*api.Stat, error) {
	return p.resolveChild(fname).Stat()
}

func (p *metaFileSystem) NewReadOnlyMemoryRegionFromFile(fname string, factory api.ReadOnlyMemoryRegionFactory) error {
	return p.resolveChild(fname).NewReadOnlyMemoryRegionFromFile(factory)
}

func (p *metaFileSystem) NewRandomAccessFile(fname string) (io.ReaderAt, error) {
	return p.resolveChild(fname).NewRandomAccessFile()
}

var sharedMissingNode = &missingNode{}

// HACK(adamb) Wayyyy to many things are hard-coded in here. Need address that.
func (p *metaFileSystem) resolveChild(name string) child {
	if strings.HasPrefix(name, "/repo/root/") {
		subpath := name[len("/repo/root"):]

		return newDynamicChild(
			func() ([]byte, error) {
				m := make(map[string]string)

				ipfsPath, err := p.mfs.IpfsPath(subpath[1:])
				if err != nil {
					return nil, err
				}
				m["IpfsPath"] = "iptf:/" + ipfsPath
				m["IpnsPath"] = "iptf:/" + p.mfs.IpnsPath(subpath[1:])
				b, err := json.Marshal(m)
				if err != nil {
					return nil, err
				}

				return b, nil
			},
			func(b []byte) error {
				m := make(map[string]string)
				err := json.Unmarshal(b, &m)
				if err != nil {
					return err
				}
				command, ok := m["command"]

				if !ok || len(m) > 1 {
					return fmt.Errorf("Expected a JSON object with the single key 'command'.")
				}

				if command == "publish" {
					return p.mfs.Publish()
				}

				return fmt.Errorf("Unknown command: %s", command)
			},
		)
	}

	return sharedMissingNode
}

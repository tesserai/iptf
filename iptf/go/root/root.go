package root

import (
	"context"
	"errors"
	"fmt"
	"io"
	"os"
	"strings"

	api "github.com/ajbouh/iptf/go/api"
	meta "github.com/ajbouh/iptf/go/meta"
	ro "github.com/ajbouh/iptf/go/ro"
	rw "github.com/ajbouh/iptf/go/rw"

	core "github.com/ipfs/go-ipfs/core"
	merkledag "github.com/ipfs/go-ipfs/merkledag"
	namesys "github.com/ipfs/go-ipfs/namesys"
	path "github.com/ipfs/go-ipfs/path"
)

const (
	// DefaultPathName is the default config dir name
	DefaultPathName = ".iptf"
	// EnvDir is the environment variable used to change the path root.
	EnvDir = "IPTF_PATH"
)

// Replace IPFS-specific errors with generic OS errors.
func rewriteError(err error) error {
	if err == nil {
		return nil
	}

	switch err.(type) {
	case path.ErrNoLink:
		return os.ErrNotExist
	}

	switch err {
	case merkledag.ErrNotFound, namesys.ErrResolveFailed:
		return os.ErrNotExist
	case path.ErrBadPath:
		return os.ErrInvalid
	}

	return err
}

type rootFs struct {
	prefixes    []string
	stripLens   []int
	mounts      []string
	filesystems []api.FileSystem
}

func (p *rootFs) mount(prefix, strip string, topLevel bool, impl api.FileSystem) {
	p.prefixes = append(p.prefixes, prefix)
	p.stripLens = append(p.stripLens, len(strip))
	var mount string
	if topLevel {
		mount = prefix[:len(prefix)-1]
	}
	p.mounts = append(p.mounts, mount)
	p.filesystems = append(p.filesystems, impl)
}

func (p *rootFs) resolveMount(fname string) (api.FileSystem, string, error) {
	for i, pfx := range p.prefixes {
		if strings.HasPrefix(fname, pfx) {
			return p.filesystems[i], fname[p.stripLens[i]:], nil
		}
	}

	for i, mount := range p.mounts {
		if fname == mount {
			return p.filesystems[i], fname[p.stripLens[i]:], nil
		}
	}

	return nil, fname, fmt.Errorf("Path has unknown prefix: %s, known prefixes: %#v", fname, p.prefixes)
}

func NewFileSystemFromNode(n *core.IpfsNode) (*rootFs, error) {
	// TODO(adamb) Generate a new key every time we start up!
	mfs, err := rw.NewMfsFileSystem(
		context.TODO(),
		n.Namesys,
		n.Resolver,
		n.DAG,
		n.PrivateKey)
	if err != nil {
		return nil, err
	}
	raw := ro.NewRawFileSystemFromNode(n.Namesys, n.DAG)
	met := meta.NewMetaFileSystem(mfs)

	// TODO(adamb) Make mfs file system allocation more dynamic and coordinate
	//     with meta package.
	// TODO(adamb) Clean up this mount, resolveMount logic. The current approach
	//     is pretty ugly.
	p := &rootFs{}
	p.mount("iptf://repo/root/", "iptf://repo/root", true, mfs)
	p.mount("iptf://ipfs/", "iptf:/", false, raw)
	p.mount("iptf://ipns/", "iptf:/", false, raw)
	p.mount("iptf://meta/", "iptf://meta", true, met)

	return p, nil
}

func (p *rootFs) Prefixes() []string {
	return []string{
		"iptf",
	}
}

func (p *rootFs) FileExists(fname string) error {
	mnt, strippedFname, err := p.resolveMount(fname)
	if err != nil {
		return rewriteError(err)
	}

	err = mnt.FileExists(strippedFname)
	return rewriteError(err)
}

func (p *rootFs) GetFileSize(fname string) (uint64, error) {
	mnt, strippedFname, err := p.resolveMount(fname)
	if err != nil {
		return 0, rewriteError(err)
	}

	size, err := mnt.GetFileSize(strippedFname)
	return size, rewriteError(err)
}

func (p *rootFs) RenameFile(src string, dst string) error {
	mnt, strippedSrc, err := p.resolveMount(src)
	if err != nil {
		return rewriteError(err)
	}

	mntDst, strippedDst, err := p.resolveMount(dst)
	if err != nil {
		return rewriteError(err)
	}

	if mnt != mntDst {
		return errors.New("source and destination filesystems do not match")
	}

	err = mnt.RenameFile(strippedSrc, strippedDst)
	return rewriteError(err)
}

func (p *rootFs) DeleteFile(fname string) error {
	mnt, strippedFname, err := p.resolveMount(fname)
	if err != nil {
		return rewriteError(err)
	}

	err = mnt.DeleteFile(strippedFname)
	return rewriteError(err)
}

func (p *rootFs) CreateDir(dirname string) error {
	mnt, strippedDirname, err := p.resolveMount(dirname)
	if err != nil {
		return rewriteError(err)
	}

	err = mnt.CreateDir(strippedDirname)
	return rewriteError(err)
}

func (p *rootFs) DeleteDir(dirname string) error {
	mnt, strippedDirname, err := p.resolveMount(dirname)
	if err != nil {
		return rewriteError(err)
	}

	err = mnt.DeleteDir(strippedDirname)
	return rewriteError(err)
}

func (p *rootFs) EachChildName(dir string, visit func(string) error) error {
	mnt, strippedDir, err := p.resolveMount(dir)
	if err != nil {
		return rewriteError(err)
	}

	err = mnt.EachChildName(strippedDir, visit)
	return rewriteError(err)
}

func (p *rootFs) Stat(fname string) (*api.Stat, error) {
	mnt, strippedFname, err := p.resolveMount(fname)
	if err != nil {
		return nil, rewriteError(err)
	}

	s, err := mnt.Stat(strippedFname)
	return s, rewriteError(err)
}

func (p *rootFs) NewReadOnlyMemoryRegionFromFile(fname string, factory api.ReadOnlyMemoryRegionFactory) error {
	mnt, strippedFname, err := p.resolveMount(fname)
	if err != nil {
		return rewriteError(err)
	}

	err = mnt.NewReadOnlyMemoryRegionFromFile(strippedFname, factory)
	return rewriteError(err)
}

func (p *rootFs) NewRandomAccessFile(fname string) (io.ReaderAt, error) {
	mnt, strippedFname, err := p.resolveMount(fname)
	if err != nil {
		return nil, rewriteError(err)
	}

	raf, err := mnt.NewRandomAccessFile(strippedFname)
	return raf, rewriteError(err)
}

func (p *rootFs) NewWritableFile(fname string) (api.WritableFile, error) {
	mnt, strippedFname, err := p.resolveMount(fname)
	if err != nil {
		return nil, rewriteError(err)
	}

	of, err := mnt.NewWritableFile(strippedFname)
	return of, rewriteError(err)
}

func (p *rootFs) NewAppendableFile(fname string) (api.WritableFile, error) {
	mnt, strippedFname, err := p.resolveMount(fname)
	if err != nil {
		return nil, rewriteError(err)
	}

	of, err := mnt.NewAppendableFile(strippedFname)
	return of, rewriteError(err)
}

var _ api.FileSystem = (*rootFs)(nil)

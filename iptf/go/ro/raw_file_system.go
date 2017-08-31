package ro

import (
	"context"
	"io"
	"os"
	gopath "path"
	"strings"

	api "github.com/ajbouh/iptf/go/api"

	core "github.com/ipfs/go-ipfs/core"
	merkledag "github.com/ipfs/go-ipfs/merkledag"
	namesys "github.com/ipfs/go-ipfs/namesys"
	path "github.com/ipfs/go-ipfs/path"
	unixfs "github.com/ipfs/go-ipfs/unixfs"
	uio "github.com/ipfs/go-ipfs/unixfs/io"
	unixfspb "github.com/ipfs/go-ipfs/unixfs/pb"
	node "github.com/ipfs/go-ipld-format"
)

type rawFileSystem struct {
	resolveDagNode   func(ctx context.Context, pstr string) (node.Node, error)
	openDagReader    func(ctx context.Context, path string) (uio.DagReader, error)
	dagReaderOpener  func(ctx context.Context, path string) (func() (uio.DagReader, error), error)
	openDagDirectory func(ctx context.Context, path string) (*uio.Directory, error)
}

func NewRawFileSystemFromNode(ns namesys.NameSystem, dagsrv merkledag.DAGService) *rawFileSystem {
	cleanPath := func(fname string) (string, error) {
		splitPaths := strings.SplitN(fname, "/", 4)
		if len(splitPaths) <= 3 {
			for _, frag := range splitPaths {
				if len(frag) > 0 && frag[0] == '.' && (len(frag) == 1 || frag[1] == '.') {
					return "", os.ErrPermission
				}
			}
			return fname, nil
		}

		splitPaths[3] = gopath.Clean(splitPaths[3])
		if strings.HasPrefix(splitPaths[3], "..") {
			return "", os.ErrPermission
		}
		cleanPath := strings.Join(splitPaths, "/")
		return cleanPath, nil
	}

	resolveDagNode := func(ctx context.Context, pstr string) (node.Node, error) {
		pstr, err := cleanPath(pstr)
		if err != nil {
			return nil, err
		}

		pth, err := path.ParsePath(pstr)
		if err != nil {
			return nil, err
		}

		r := &path.Resolver{
			DAG:         dagsrv,
			ResolveOnce: uio.ResolveUnixfsOnce,
		}

		return core.Resolve(ctx, ns, r, pth)
	}

	return &rawFileSystem{
		resolveDagNode: resolveDagNode,
		openDagDirectory: func(ctx context.Context, path string) (*uio.Directory, error) {
			dagNode, err := resolveDagNode(ctx, path)
			if err != nil {
				return nil, err
			}

			return uio.NewDirectoryFromNode(dagsrv, dagNode)
		},
		dagReaderOpener: func(ctx context.Context, path string) (func() (uio.DagReader, error), error) {
			dagNode, err := resolveDagNode(ctx, path)
			if err != nil {
				return nil, err
			}

			return func() (uio.DagReader, error) { return uio.NewDagReader(ctx, dagNode, dagsrv) }, nil
		},
		openDagReader: func(ctx context.Context, path string) (uio.DagReader, error) {
			dagNode, err := resolveDagNode(ctx, path)
			if err != nil {
				return nil, err
			}

			return uio.NewDagReader(ctx, dagNode, dagsrv)
		},
	}
}

func (p *rawFileSystem) NewWritableFile(fname string) (api.WritableFile, error) {
	return nil, os.ErrPermission
}

func (p *rawFileSystem) NewAppendableFile(fname string) (api.WritableFile, error) {
	return nil, os.ErrPermission
}

func (p *rawFileSystem) RenameFile(src string, dst string) error {
	return os.ErrPermission
}

func (p *rawFileSystem) DeleteFile(fname string) error {
	return os.ErrPermission
}

func (p *rawFileSystem) CreateDir(dirname string) error {
	return os.ErrPermission
}

func (p *rawFileSystem) DeleteDir(dirname string) error {
	return os.ErrPermission
}

func (p *rawFileSystem) FileExists(fname string) error {
	_, err := p.resolveDagNode(context.Background(), fname)
	return err
}

func (p *rawFileSystem) GetFileSize(fname string) (uint64, error) {
	dr, err := p.openDagReader(context.Background(), fname)
	if err != nil {
		return 0, err
	}
	defer dr.Close()

	return dr.Size(), nil
}

func (p *rawFileSystem) EachChildName(dirname string, visit func(string) error) error {
	ctx := context.Background()
	dir, err := p.openDagDirectory(ctx, dirname)
	if err != nil {
		return err
	}

	links, err := dir.Links(ctx)
	if err != nil {
		return err
	}

	for _, link := range links {
		err = visit(link.Name)
		if err != nil {
			return err
		}
	}

	return nil
}

func (p *rawFileSystem) Stat(fname string) (*api.Stat, error) {
	ctx := context.Background()
	dagNode, err := p.resolveDagNode(ctx, fname)
	if err != nil {
		return nil, err
	}

	s, err := dagNode.Stat()
	if err != nil {
		return nil, err
	}

	isDir := false
	if pn, ok := dagNode.(*merkledag.ProtoNode); ok {
		d, err := unixfs.FromBytes(pn.Data())
		if err != nil {
			return nil, err
		}

		isDir = d.GetType() == unixfspb.Data_Directory
	}

	st := &api.Stat{
		IsDirectory: isDir,
		Size:        int64(s.DataSize),
	}
	return st, nil
}

func (p *rawFileSystem) NewReadOnlyMemoryRegionFromFile(fname string, factory api.ReadOnlyMemoryRegionFactory) error {
	dr, err := p.openDagReader(context.Background(), fname)
	if err != nil {
		return err
	}

	defer dr.Close()

	size := dr.Size()
	if err != nil {
		return err
	}

	return factory(int(size), dr.Read)
}

type rawRandomAccessFile struct {
	newDagReader func() (uio.DagReader, error)
}

func (p *rawRandomAccessFile) ReadAt(scratch []byte, offset int64) (int, error) {
	dr, err := p.newDagReader()
	if err != nil {
		return 0, err
	}

	defer dr.Close()

	filen := dr.Size()

	if uint64(offset) > filen {
		return int(filen - uint64(offset)), nil
	}

	_, err = dr.Seek(int64(offset), io.SeekStart)
	if err != nil {
		return 0, err
	}

	return dr.CtxReadFull(context.Background(), scratch)
}

var _ io.ReaderAt = (*rawRandomAccessFile)(nil)

func (p *rawFileSystem) NewRandomAccessFile(fname string) (io.ReaderAt, error) {
	newDagReader, err := p.dagReaderOpener(context.Background(), fname)
	if err != nil {
		return nil, err
	}

	return &rawRandomAccessFile{newDagReader}, nil
}

var _ api.FileSystem = (*rawFileSystem)(nil)

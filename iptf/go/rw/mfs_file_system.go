package rw

import (
	"context"
	"errors"
	"fmt"
	"io"
	"os"
	gopath "path"

	api "github.com/ajbouh/iptf/go/api"

	cid "github.com/ipfs/go-cid"
	core "github.com/ipfs/go-ipfs/core"
	dag "github.com/ipfs/go-ipfs/merkledag"
	mfs "github.com/ipfs/go-ipfs/mfs"
	namesys "github.com/ipfs/go-ipfs/namesys"
	path "github.com/ipfs/go-ipfs/path"
	ft "github.com/ipfs/go-ipfs/unixfs"
	logging "github.com/ipfs/go-log"
	ci "github.com/libp2p/go-libp2p-crypto"
	peer "github.com/libp2p/go-libp2p-peer"
)

var log = logging.Logger("mfs_file_system")

type MfsFileSystem struct {
	ipnsPrefix string
	ipfsPrefix string
	root       *mfs.Root
}

func ipnsPubFunc(ns namesys.NameSystem, k ci.PrivKey) mfs.PubFunc {
	return func(ctx context.Context, c *cid.Cid) error {
		return ns.Publish(ctx, k, path.FromCid(c))
	}
}

func NewMfsFileSystem(
	ctx context.Context,
	ns namesys.NameSystem,
	pathResolver *path.Resolver,
	dagsrv dag.DAGService,
	k ci.PrivKey) (*MfsFileSystem, error) {

	pid, err := peer.IDFromPrivateKey(k)
	if err != nil {
		return nil, err
	}

	name := pid.Pretty()
	ipnsPrefix := "/ipns/" + name
	ipfsPrefix := "/ipfs"

	p, err := path.ParsePath(ipnsPrefix)
	if err != nil {
		log.Errorf("mkpath %s: %s", name, err)
		return nil, err
	}

	node, err := core.Resolve(ctx, ns, pathResolver, p)
	switch err {
	case nil:
	case namesys.ErrResolveFailed:
		node = ft.EmptyDirNode()
	default:
		log.Errorf("looking up %s: %s", p, err)
		return nil, err
	}

	pbnode, ok := node.(*dag.ProtoNode)
	if !ok {
		return nil, dag.ErrNotProtobuf
	}

	root, err := mfs.NewRoot(ctx, dagsrv, pbnode, ipnsPubFunc(ns, k))
	if err != nil {
		return nil, err
	}

	return &MfsFileSystem{
		ipnsPrefix: ipnsPrefix,
		ipfsPrefix: ipfsPrefix,
		root:       root,
	}, nil
}

func (p *MfsFileSystem) IpnsPath(path string) string {
	if path == "" {
		return p.ipnsPrefix
	}

	return p.ipnsPrefix + "/" + path
}

func (p *MfsFileSystem) Publish() error {
	p.root.Sync()
	return nil
}

func (p *MfsFileSystem) IpfsPath(path string) (string, error) {
	n, err := mfs.Lookup(p.root, path)
	if err != nil {
		return "", err
	}

	n2, err := n.GetNode()
	if err != nil {
		return "", err
	}
	s, err := n2.Stat()
	if err != nil {
		return "", err
	}

	return p.ipfsPrefix + "/" + s.Hash, err
}

func (p *MfsFileSystem) FileExists(fname string) error {
	_, err := mfs.Lookup(p.root, fname)
	if err != nil {
		return err
	}

	return nil
}

func (p *MfsFileSystem) GetFileSize(fname string) (uint64, error) {
	fi, err := getMfsFile(p.root, fname, false)
	if err != nil {
		return 0, err
	}

	size, err := fi.Size()
	if err != nil {
		return 0, err
	}

	return uint64(size), nil
}

func (p *MfsFileSystem) RenameFile(src string, dst string) error {
	err := mfs.Mv(p.root, src, dst)
	if err != nil {
		return err
	}

	return nil
}

func rmPath(path string, recursive bool, root *mfs.Root) error {
	if path == "/" {
		return errors.New("cannot delete root")
	}

	// 'rm a/b/c/' will fail unless we trim the slash at the end
	if path[len(path)-1] == '/' {
		path = path[:len(path)-1]
	}

	dir, name := gopath.Split(path)
	parent, err := mfs.Lookup(root, dir)
	if err != nil {
		return fmt.Errorf("parent lookup: %s", err)
	}

	pdir, ok := parent.(*mfs.Directory)
	if !ok {
		return fmt.Errorf("No such file or directory: %s", path)
	}

	var success bool
	defer func() {
		if success {
			err := pdir.Flush()
			if err != nil {
				fmt.Println(err.Error())
			}
		}
	}()

	// if '-r' specified, don't check file type (in bad scenarios, the block may not exist)
	if recursive {
		err := pdir.Unlink(name)
		if err != nil {
			return err
		}

		success = true
		return nil
	}

	childi, err := pdir.Child(name)
	if err != nil {
		return err
	}

	switch childi.(type) {
	case *mfs.Directory:
		return fmt.Errorf("%s is a directory, use -r to remove directories", path)
	default:
		err := pdir.Unlink(name)
		if err != nil {
			return err
		}

		success = true
	}

	return nil
}

func (p *MfsFileSystem) DeleteFile(fname string) error {
	err := rmPath(fname, false, p.root)
	if err != nil {
		return err
	}

	return nil
}

func (p *MfsFileSystem) CreateDir(dirname string) error {
	err := mfs.Mkdir(p.root, dirname, false, true)
	if err != nil {
		return err
	}

	return nil
}

func (p *MfsFileSystem) DeleteDir(dirname string) error {
	err := rmPath(dirname, true, p.root)
	if err != nil {
		return err
	}

	return nil
}

func (p *MfsFileSystem) EachChildName(dir string, visit func(string) error) error {
	fsn, err := mfs.Lookup(p.root, dir)
	if err != nil {
		return err
	}

	switch fsn := fsn.(type) {
	case *mfs.Directory:
		ctx := context.TODO()

		err = fsn.ForEachEntry(ctx, func(nl mfs.NodeListing) error {
			return visit(nl.Name)
		})
		if err != nil {
			return err
		}
		return nil
	case *mfs.File:
		return errors.New("Is a file, not a directory")
	default:
		return errors.New("Unknown type, not a directory")
	}

	return nil
}

func (p *MfsFileSystem) Stat(fname string) (*api.Stat, error) {
	fsn, err := mfs.Lookup(p.root, fname)
	if err != nil {
		return nil, err
	}

	if fi, ok := fsn.(*mfs.File); ok {
		length, err := fi.Size()
		if err != nil {
			return nil, err
		}

		return &api.Stat{
			IsDirectory: false,
			Size:        length,
		}, nil
	}

	return &api.Stat{
		IsDirectory: true,
	}, nil
}

func (p *MfsFileSystem) NewReadOnlyMemoryRegionFromFile(fname string, factory api.ReadOnlyMemoryRegionFactory) error {
	fi, err := getMfsFile(p.root, fname, false)
	if err != nil {
		return err
	}

	rfd, err := fi.Open(mfs.OpenReadOnly, false)
	if err != nil {
		return err
	}

	defer rfd.Close()

	filen, err := rfd.Size()
	if err != nil {
		return err
	}

	return factory(int(filen), rfd.Read)
}

type mfsRandomAccessFile mfs.File

func (p *mfsRandomAccessFile) ReadAt(scratch []byte, offset int64) (int, error) {
	rfd, err := (*mfs.File)(p).Open(mfs.OpenReadOnly, false)
	if err != nil {
		return 0, err
	}

	defer rfd.Close()

	filen, err := rfd.Size()
	if err != nil {
		return 0, err
	}

	if int64(offset) > filen {
		return int(filen - int64(offset)), nil
	}

	_, err = rfd.Seek(int64(offset), io.SeekStart)
	if err != nil {
		return 0, err
	}

	return rfd.CtxReadFull(context.TODO(), scratch)
}

func (p *MfsFileSystem) NewRandomAccessFile(fname string) (io.ReaderAt, error) {
	fi, err := getMfsFile(p.root, fname, false)
	if err != nil {
		return nil, err
	}

	return (*mfsRandomAccessFile)(fi), err
}

func (p *MfsFileSystem) NewWritableFile(fname string) (api.WritableFile, error) {
	return newMfsWritableFile(fname, true, true, true, p.root)
}

func (p *MfsFileSystem) NewAppendableFile(fname string) (api.WritableFile, error) {
	return newMfsWritableFile(fname, true, false, true, p.root)
}

func newMfsWritableFile(path string, create, truncate, sync bool, root *mfs.Root) (api.WritableFile, error) {
	fi, err := getMfsFile(root, path, create)
	if err != nil {
		return nil, err
	}

	wfd, err := fi.Open(mfs.OpenWriteOnly, sync)
	if err != nil {
		return nil, err
	}

	if truncate {
		if err := wfd.Truncate(0); err != nil {
			wfd.Close()
			return nil, err
		}
		_, err = wfd.Seek(0, io.SeekStart)
		if err != nil {
			wfd.Close()
			return nil, err
		}
	}

	_, err = wfd.Seek(0, io.SeekEnd)
	if err != nil {
		wfd.Close()
		return nil, err
	}

	return wfd, nil
}

func getMfsFile(r *mfs.Root, path string, create bool) (*mfs.File, error) {
	target, err := mfs.Lookup(r, path)
	switch err {
	case nil:
		fi, ok := target.(*mfs.File)
		if !ok {
			return nil, fmt.Errorf("%s was not a file", path)
		}
		return fi, nil

	case os.ErrNotExist:
		if !create {
			return nil, err
		}

		// if create is specified and the file doesnt exist, we create the file
		dirname, fname := gopath.Split(path)
		pdiri, err := mfs.Lookup(r, dirname)
		if err != nil {
			// log.Error("lookupfail ", dirname)
			return nil, err
		}
		pdir, ok := pdiri.(*mfs.Directory)
		if !ok {
			return nil, fmt.Errorf("%s was not a directory", dirname)
		}

		nd := dag.NodeWithData(ft.FilePBData(nil, 0))
		err = pdir.AddChild(fname, nd)
		if err != nil {
			return nil, err
		}

		fsn, err := pdir.Child(fname)
		if err != nil {
			return nil, err
		}

		fi, ok := fsn.(*mfs.File)
		if !ok {
			return nil, errors.New("Expected *mfs.File, didnt get it. This is likely a race condition.")
		}
		return fi, nil

	default:
		return nil, err
	}
}

var _ api.FileSystem = (*MfsFileSystem)(nil)

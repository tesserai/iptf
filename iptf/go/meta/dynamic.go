package meta

import (
	"bytes"
	"io"
	"os"
	"sync"

	api "github.com/ajbouh/iptf/go/api"
)

func newDynamicChild(render func() ([]byte, error), accept func([]byte) error) child {
	return &dynamicChild{
		render: render,
		accept: accept,
		s:      nil,
		m:      &sync.Mutex{},
	}
}

type bufferedAcceptor struct {
	buf    *bytes.Buffer
	accept func([]byte) error
}

func (p *bufferedAcceptor) Flush() error {
	return nil
}

func (p *bufferedAcceptor) Sync() error {
	return nil
}

func (p *bufferedAcceptor) Close() error {
	return p.accept(p.buf.Bytes())
}

func (p *bufferedAcceptor) Write(b []byte) (int, error) {
	return p.buf.Write(b)
}

var _ api.WritableFile = (*bufferedAcceptor)(nil)

type dynamicChild struct {
	accept func([]byte) error
	render func() ([]byte, error)
	s      *[]byte
	m      *sync.Mutex
}

func (p *dynamicChild) slice() ([]byte, error) {
	p.m.Lock()
	defer p.m.Unlock()
	if p.s != nil {
		return *p.s, nil
	}

	s, err := p.render()
	if err != nil {
		return []byte{}, err
	}

	p.s = &s
	return s, err
}

func (p *dynamicChild) NewWritableFile() (api.WritableFile, error) {
	if p.accept == nil {
		return nil, os.ErrPermission
	}

	return &bufferedAcceptor{&bytes.Buffer{}, p.accept}, nil
}

func (p *dynamicChild) NewAppendableFile() (api.WritableFile, error) {
	return p.NewWritableFile()
}

func (p *dynamicChild) Exists() error {
	return nil
}

func (p *dynamicChild) EachChildName(visit func(string) error) error {
	return nil
}

func (p *dynamicChild) GetFileSize() (uint64, error) {
	s, err := p.slice()
	if err != nil {
		return 0, err
	}
	return uint64(len(s)), nil
}

func (p *dynamicChild) Stat() (*api.Stat, error) {
	s, err := p.slice()
	if err != nil {
		return nil, err
	}

	return &api.Stat{
		IsDirectory: false,
		Size:        int64(len(s)),
	}, nil
}

func (p *dynamicChild) NewReadOnlyMemoryRegionFromFile(factory api.ReadOnlyMemoryRegionFactory) error {
	s, err := p.slice()
	if err != nil {
		return err
	}

	buf := bytes.NewReader(s)
	factory(len(s), buf.Read)
	return nil
}

func (p *dynamicChild) NewRandomAccessFile() (io.ReaderAt, error) {
	s, err := p.slice()
	if err != nil {
		return nil, err
	}

	return bytes.NewReader(s), nil
}

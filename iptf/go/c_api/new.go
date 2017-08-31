package c_api

import "C"

import (
	"fmt"

	wrap "github.com/ajbouh/iptf/go/filesys_wrap"
	ipfsinit "github.com/ajbouh/iptf/go/ipfsinit"
	impl "github.com/ajbouh/iptf/go/root"
)

//export NewIpfsFileSystem
func NewIpfsFileSystem(repoRoot string, init, online bool) uintptr {
	// We use this function to make it possible to create a new file system
	// without needing to register it. This helps us write more isolated tests.

	n, err := ipfsinit.ConstructAndMaybeInitNode(repoRoot, init, online)
	if err != nil {
		fmt.Printf("Something bad happened", err.Error())
		return 0
	}

	fs, err := impl.NewFileSystemFromNode(n)
	if err != nil {
		fmt.Printf("Something bad happened", err.Error())
		return 0
	}

	wfs := wrap.NewFileSystem(fs)
	return wfs.DirectorFileSystem().Swigcptr()
}

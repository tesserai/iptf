package main

import (
	"fmt"
	"net"
	"os/user"

	tfs "github.com/ajbouh/iptf/go/filesys"
	wrap "github.com/ajbouh/iptf/go/filesys_wrap"
	ipfsinit "github.com/ajbouh/iptf/go/ipfsinit"
	iptf "github.com/ajbouh/iptf/go/root"
)

// When we're building a .so file, we need to register our filesystem provider
// during module initialization so no user code is needed to use the filesystem.

// Basic configuration is possible via environment variables.
// - Set IPTF_OFFLINE to a non-empty value to run the filesystem in offline mode.
// - Set IPTF_READY_PORT to a TCP port that should be dialed once filesystem
//   registration is complete.

// NB(adamb) Since we want to allow our tests to set an environment variable
//   before dlopen'ing this .so, we need to use tfs.LookupEnv to read environment
//   variables. The default go functions for reading environment variables read
//   a datastructure that isn't modifiable by, e.g., Python's os.Environ.

func init() {
	err := initImpl()
	if err != nil {
		fmt.Println(err.Error())
	}
}

// TODO(adamb) Switch over to a real logger.
func initImpl() error {
	rootPath, err := pathRoot()
	if err != nil {
		return fmt.Errorf("Failed to discover IPTF path: %s", err)
	}

	// Assume we're willing to init the rootPath if needed.
	init := true

	// Assume we want to be online.
	online := true
	offlineStr, ok := tfs.LookupEnv("IPTF_OFFLINE")
	if ok && offlineStr != "" {
		online = false
	}

	fmt.Println("Using rootPath", rootPath)
	n, err := ipfsinit.ConstructAndMaybeInitNode(rootPath, init, online)
	if err != nil {
		return err
	}

	fs, err := iptf.NewFileSystemFromNode(n)
	if err != nil {
		return fmt.Errorf("Failed to construct node: %s", err)
	}

	wfs := wrap.NewFileSystem(fs)
	factory := tfs.IptfSingletonFileSystemFactory(wfs.DirectorFileSystem())
	env := tfs.EnvDefault()
	for _, prefix := range fs.Prefixes() {
		// TODO(adamb) Check result of RegisterFileSystem
		fmt.Println("Registering", prefix)
		env.RegisterFileSystem(prefix, factory)
	}

	portStr, ok := tfs.LookupEnv("IPTF_READY_PORT")
	fmt.Println("Will connect to", portStr, ok)
	if ok {
		notifyAddr := "127.0.0.1:" + portStr
		err := notifyReady(notifyAddr)
		if err != nil {
			return fmt.Errorf("Couldn't notify %s that IPTF is ready: %s", notifyAddr, err)
		}
	}

	return nil
}

// PathRoot returns the default configuration root directory
func pathRoot() (string, error) {
	dir, ok := tfs.LookupEnv(iptf.EnvDir)
	if ok && dir != "" {
		return dir, nil
	}

	u, err := user.Current()
	if err != nil {
		return "", err
	}

	return u.HomeDir + "/" + iptf.DefaultPathName, nil
}

func notifyReady(address string) error {
	conn, err := net.Dial("tcp", address)
	if err == nil {
		conn.Close()
	}
	return err
}

func main() {}

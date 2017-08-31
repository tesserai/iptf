package ipfsinit

import (
	"context"
	"fmt"
	"os"
	"sort"

	core "github.com/ipfs/go-ipfs/core"
	fsrepo "github.com/ipfs/go-ipfs/repo/fsrepo"
	logging "github.com/ipfs/go-log"
)

func ConstructAndMaybeInitNode(repoRoot string, init, online bool) (*core.IpfsNode, error) {
	daemonLocked, err := fsrepo.LockedByOtherProcess(repoRoot)
	if err != nil {
		return nil, err
	}

	if daemonLocked {
		return nil, fmt.Errorf("An instance of ipfs is already running on %s", repoRoot)
	}

	if init {
		if !fsrepo.IsInitialized(repoRoot) {
			initWithDefaults(os.Stderr, repoRoot)
		}
	}

	return constructNode(repoRoot, online)
}

func constructNode(rootPath string, online bool) (*core.IpfsNode, error) {
	r, err := fsrepo.Open(rootPath)
	if err != nil { // repo is owned by the node
		return nil, err
	}

	n, err := core.NewNode(context.TODO(), &core.BuildCfg{
		Online:    online,
		Repo:      r,
		Permament: true,
		Routing:   core.DHTClientOption,
	})
	if err != nil {
		return nil, err
	}

	if !online {
		n.SetupOfflineRouting()
	}

	printSwarmAddrs(n)

	logging.SetDebugLogging()

	return n, nil
}

func printSwarmAddrs(node *core.IpfsNode) {
	if !node.OnlineMode() {
		fmt.Println("Swarm not listening, running in offline mode.")
		return
	}
	var addrs []string
	for _, addr := range node.PeerHost.Addrs() {
		addrs = append(addrs, addr.String())
	}
	sort.Sort(sort.StringSlice(addrs))

	for _, addr := range addrs {
		fmt.Printf("Swarm listening on %s\n", addr)
	}
}

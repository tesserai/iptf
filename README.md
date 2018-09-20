# IPTF

## A distributed filesystem for TensorFlow models, data, and logs

IPTF brings the best parts of [IPFS](https://ipfs.io) into the world of TensorFlow. If you're not familiar with IPFS, think of it as a cross between git and BitTorrent: a global peer-to-peer network of machines that provide instant, reliable access to massive datasets.

## Why should I use IPTF?
IPTF is free, it’s peer-to-peer and it requires zero configuration. Use IPTF in your machine learning workflow to handle enormous quantities of data without needing to setup, configure, or orchestrate a separate storage solution.

### Fully integrated
By embedding an IPFS daemon directly into TensorFlow, IPTF provides seamless read/write access to the entire IPFS network. IPTF is fully integrated with full [tf.gfile](https://www.tensorflow.org/api_docs/python/tf/gfile/GFile) and all of the [io_ops](https://www.tensorflow.org/api_guides/python/io_ops), so `iptf://` prefixed paths can be used in Python directly or with any core file operation in a TensorFlow graph.

### Quicker, easier access to popular datasets
Instead of downloading each of the [MNIST](http://yann.lecun.com/exdb/mnist/) files and storing them somewhere on your machine, just use the path `"iptf://ipfs/QmazxWBPrSfTzkuzQNvyzYWx438q98Q1pQ7vRJkQZh7x97"`, and TensorFlow will fetch and cache the data you need on the fly.

The [QmazxWBPrSfTzkuzQNvyzYWx438q98Q1pQ7vRJkQZh7x97](https://gateway.ipfs.io/ipfs/QmazxWBPrSfTzkuzQNvyzYWx438q98Q1pQ7vRJkQZh7x97) part of the path is the fingerprint of the MNIST dataset. The only file in the world that has that fingerprint is the MNIST dataset. So not only is it enough information to request that file from the network, it's also enough information to check that you received a perfect, uncorrupted copy of MNIST. Similar to BitTorrent,  IPTF downloads pieces of your files from many computers in parallel and still guarantees you're getting exactly the right sequence of bytes.

### Better bandwidth usage
Addressing files and directories by their content helps optimize bandwidth usage as well. Fetching cached blocks from peers on your local network conserves use of internet bandwidth for data that hasn't been fetched from the Internet yet.

### Models in IPTF
Datasets aren't the only large files in machine learning. Model weights get large as well. You can use IPTF to load a model like Inception in a single line of code.

### Reproducibility and IPTF
Reproducibility is a key aspect of machine learning. IPTF provides a simple way to reproduce any training result at any time. When IPTF loads data to feed to a model, it remembers the fingerprint of the data in a way that's easy to refer to later, similar to git’s reflog. This makes it easy to reuse any data you've used in the past to reproduce a result or compare a new model to an old one.

### Storage efficiency and IPTF
Using IPTF during your project’s exploration phase has a bonus benefit: storage efficiency. Whenever new data is stored in IPTF, only the blocks that differ from existing files will be stored.

## Developing IPTF

### Running tests

Run Python smoke tests
```
$ bazel run //iptf/python:file_system_test
```

Run C++ `tensorflow::FileSystem` tests
```
$ bazel run //iptf/cpp:file_system_test
```

### Testing other projects
To experiment with IPTF-enabled TensorFlow on an existing project while still building from source
```
$ bazel run //iptf/python:iptf -- python foo.py bar

```

## Pre-launch task list

- [ ] Walkthough of how to use IPTF in a real project
- [ ] Example Jupyter notebook
- [ ] Build and test pip package on macOS
- [ ] Get build working on linux
- [ ] Build and test pip package on linux
- [x] Run `go fmt` on the source
- [ ] Clean up Python smoke test
- [ ] Check that docker container that can run IPTF-enabled Tensorboard
- [ ] Write up real README
- [ ] Write up build instructions
- [ ] Push upstream SWIG patch(es)
- [ ] Push upstream TensorFlow patch(es)
- [ ] Push upstream go-ipfs patch(es)
- [ ] `iptf` standalone command
  - [ ] `iptf serve [...]`
  - [x] `iptf tensorboard ...`
  - [x] `iptf python ...`
- [ ] Performance testing
  - [ ] IPFS read/write performance
  - [ ] IPFS network performance
  - [ ] No memory leaks load

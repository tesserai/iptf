workspace(name = "iptf")

local_repository(
  name = "org_tensorflow",
  path = "tensorflow",
)

local_repository(
  name = "org_tensorflow_tensorboard",
  path = "tensorboard",
)

local_repository(
  name = "io_ipfs_go_ipfs",
  path = "go-ipfs",
)

http_archive(
    name = "io_bazel_rules_go",
    urls = [
        "https://github.com/bazelbuild/rules_go/archive/0.5.3.tar.gz",
    ],
    sha256 = "0281f223a7a2feca80b17514aff0709611ac1a23a32565c6ea71bac8a98317ba",
    strip_prefix = "rules_go-0.5.3",
)


# TensorFlow depends on "io_bazel_rules_closure" so we need this here.
# Needs to be kept in sync with the same target in TensorFlow's WORKSPACE file.
http_archive(
    name = "io_bazel_rules_closure",
    sha256 = "4be8a887f6f38f883236e77bb25c2da10d506f2bf1a8e5d785c0f35574c74ca4",
    strip_prefix = "rules_closure-aac19edc557aec9b603cd7ffe359401264ceff0d",
    urls = [
        "http://mirror.bazel.build/github.com/bazelbuild/rules_closure/archive/aac19edc557aec9b603cd7ffe359401264ceff0d.tar.gz",  # 2017-05-10
        "https://github.com/bazelbuild/rules_closure/archive/aac19edc557aec9b603cd7ffe359401264ceff0d.tar.gz",
    ],
)

# Please add all new TFI dependencies in workspace.bzl.
load('//iptf:workspace.bzl', 'iptf_workspace')
iptf_workspace()

# Specify the minimum required bazel version.
load("@org_tensorflow//tensorflow:workspace.bzl", "check_version")
check_version("0.4.5")

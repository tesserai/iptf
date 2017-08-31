load(':swig.bzl', "swig_gen")
load("@io_bazel_rules_go//go:def.bzl", "go_library")

def go_swig_library(
    *,
    name,
    srcs,
    module_name,
    deps=[],
    cdeps=[],
    **kwargs):
  hdrs = []
  swig_srcs = []
  go_srcs = []
  for src in srcs:
    if src.endswith(".i") or src.endswith(".swigcxx"):
      swig_srcs += [src]
    elif src.endswith(".h"):
      hdrs += [src]
    else:
      go_srcs += [src]

  native.cc_inc_library(
    name="cc_inc_lib_" + name,
    hdrs=hdrs,
    deps=cdeps,
  )

  swig_gen(
      name="swig_gen_" + name,
      module_name=module_name,
      srcs=srcs,
      language="go",
      # Since swig_gen doesn't know what language-specific files will be
      # emitted, we specify them explicitly here.
      outs=[
        module_name + ".go",
      ],
      swig_args=[
        "-cgo",
        # TODO(adamb) Should dynamically detect intgosize
        "-intgosize", "64",
      ],
      deps=[
        ":cc_inc_lib_" + name,
      ],
      toolchain_deps=["//tools/defaults:crosstool"],
  )

  go_library(
      cgo=True,
      name=name,
      srcs=[
        ":swig_gen_" + name,
      ] + go_srcs,
      cdeps=[
        ":cc_inc_lib_" + name,
      ],
      deps=deps,
      **kwargs)

# From @org_tensorflow//tensorflow/tensorflow/tensorflow.bzl
def _get_repository_roots(ctx, files):
  """Returns abnormal root directories under which files reside.

  When running a ctx.action, source files within the main repository are all
  relative to the current directory; however, files that are generated or exist
  in remote repositories will have their root directory be a subdirectory,
  e.g. bazel-out/local-fastbuild/genfiles/external/jpeg_archive. This function
  returns the set of these devious directories, ranked and sorted by popularity
  in order to hopefully minimize the number of I/O system calls within the
  compiler, because includes have quadratic complexity.
  """
  result = {}
  for f in files:
    root = f.root.path
    if root:
      if root not in result:
        result[root] = 0
      result[root] -= 1
    work = f.owner.workspace_root
    if work:
      if root:
        root += "/"
      root += work
    if root:
      if root not in result:
        result[root] = 0
      result[root] -= 1
  return [k for v, k in sorted([(v, k) for k, v in result.items()])]

# Bazel rules for building swig files.
def _swig_gen_impl(ctx):
  swig_includes = set()
  swig_srcs = set()
  other_srcs = set()
  for src in ctx.files.srcs:
    if src.path.endswith(".swigcxx"):
      swig_srcs += [src]
      continue
    if src.path.endswith(".i"):
      continue
    if src.path.endswith(".h"):
      continue
    other_srcs += [src]

  lang = ctx.attr.language

  inputs = set()
  inputs += ctx.files.srcs
  inputs += [ctx.executable._swig]

  for dep in ctx.attr.deps:
    inputs += dep.cc.transitive_headers
  inputs += ctx.files._swiglib
  inputs += ctx.files.toolchain_deps
  swig_include_dirs = set(_get_repository_roots(ctx, inputs))
  for swig_include_dir in sorted([f.dirname for f in ctx.files._swiglib]):
    if swig_include_dir.endswith("/" + lang) or \
        swig_include_dir.endswith("/Lib") or \
        swig_include_dir.endswith("/cffi") or \
        swig_include_dir.endswith("/std") or \
        swig_include_dir.endswith("/typemaps"):
      swig_include_dirs += [swig_include_dir]

  module_name = ctx.attr.module_name

  swig_src = list(swig_srcs)[0]
  args = []
  cc_out_tmp = ctx.actions.declare_file("intermediate.cc", sibling=ctx.outputs.cc_out)
  args += [
      "-" + lang,
      "-v",
      "-module", module_name,
      "-oh", ctx.outputs.h_out.path,
      "-o", cc_out_tmp.path,
      "-outdir", cc_out_tmp.dirname + "/",
  ]
  args += ctx.attr.swig_args
  args += ["-l" + f.path for f in swig_includes]
  args += ["-I" + i for i in swig_include_dirs]
  args += ["-c++"]
  args += [swig_src.path]

  base_outputs = [ctx.outputs.h_out]
  base_outputs += ctx.outputs.outs

  ctx.actions.run(
      executable=ctx.executable._swig,
      arguments=args,
      inputs=list(inputs),
      outputs=base_outputs + [cc_out_tmp],
      mnemonic="Swig",
      progress_message="SWIGing " + swig_src.path)

  # NOTE(adamb) SWIG will generate an #include "%{module_name}.h",
  # but when we compile this library with Bazel, the compiler will
  # expect a fully-qualified path, including parent directories.
  # Use sed to rewrite the include in question.
  header_path = ctx.outputs.h_out.basename
  package_path = "/".join(ctx.build_file_path.split("/")[:-1])
  ctx.actions.run_shell(
    command="sed -e 's!%s!%s/&!' < $1 > $2" % (header_path, package_path),
    arguments=[cc_out_tmp.path,ctx.outputs.cc_out.path],
    inputs=[cc_out_tmp],
    outputs=[ctx.outputs.cc_out]
  )

  outputs = base_outputs + [ctx.outputs.cc_out]
  return struct(files=set(outputs))

swig_gen = rule(
    attrs={
        "srcs":
            attr.label_list(
                mandatory=True,
                allow_files=True,),
        "swig_includes":
            attr.label_list(
                cfg="data",
                allow_files=True,),
        "swig_args": attr.string_list(),
        "language":
            attr.string(
                mandatory=True,),
        "deps":
            attr.label_list(
                allow_files=True,
                providers=["cc"],),
        "outs": attr.output_list(),
        "toolchain_deps":
            attr.label_list(
                allow_files=True,),
        "module_name":
            attr.string(mandatory=True),
        "_swig":
            attr.label(
                default=Label("@swig//:swig"),
                executable=True,
                cfg="host",),
        "_swiglib":
            attr.label(
                default=Label("@swig//:templates"),
                allow_files=True,),
    },
    outputs={
        "h_out": "%{module_name}_wrap.h",
        "cc_out": "%{module_name}_wrap.cc",
    },
    output_to_genfiles=True,
    implementation=_swig_gen_impl,)

# Copyright 2015 The TensorFlow Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================

"""A command line interface for IPTF functionality."""

from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

import argparse
import os
import sys

def run_python(args):
  import runpy
  sys.argv = [args.script, *args.args]
  sys.path.insert(0, os.path.dirname(args.script))
  runpy.run_path(args.script, None, '__main__')

def run_serve(args):
  print("`iptf serve` NOT YET IMPLEMENTED")
  exit(1)

def run_tensorboard(args):
  passthrough_args = args.args
  if len(passthrough_args) > 0 and passthrough_args[0] == '--':
    passthrough_args = passthrough_args[1:]
  sys.argv = ['iptf tensorboard', *passthrough_args]

  import tensorflow as tf
  import tensorboard.main as tb_main

  if args.launch:
    import subprocess
    orig_make_simple_server = tb_main.make_simple_server
    def tb_main_make_simple_server(*a, **kw):
      server, url = orig_make_simple_server(*a, **kw)
      subprocess.Popen(["/usr/bin/open", url])
      return server, url
    tb_main.make_simple_server = tb_main_make_simple_server

  tf.app.run(tb_main.main)


parser = argparse.ArgumentParser(prog='iptf')
parser.add_argument('-u', dest='unbuffered', action='store_true', help='Make stdout unbuffered')
parser.add_argument('--chdir', type=str, help='Change to directory before doing anything')
subparsers = parser.add_subparsers(help='sub-command help')

parser_serve = subparsers.add_parser('serve', help="""
Serve content to others across the network and optionally import one or more existing paths.
""")
parser_serve.add_argument('path', type=str, nargs='*', help='Import given path(s) and serve it to others')
parser_serve.set_defaults(func=run_serve)

parser_tensorboard = subparsers.add_parser('tensorboard', help='Start a local Tensorboard server')
parser_tensorboard.add_argument('--launch', dest='launch', action='store_true', help="Launch in default browser (default)")
parser_tensorboard.add_argument('--no-launch', dest='launch', action='store_false', help="Don't launch a browser")
parser_tensorboard.set_defaults(launch=True)
parser_tensorboard.add_argument('args', type=str, nargs=argparse.REMAINDER)
parser_tensorboard.set_defaults(func=run_tensorboard)

parser_python = subparsers.add_parser('python', help='Launch a Python script after loading the IPTF plugin')
parser_python.add_argument('script', type=str, help='Script to run')
parser_python.add_argument('args', type=str, nargs=argparse.REMAINDER, help='Script arguments')
parser_python.set_defaults(func=run_python)

if __name__ == '__main__':
  args = parser.parse_args(sys.argv[1:])
  if args.unbuffered:
    import io
    # Workaround from https://bugs.python.org/issue17404
    binstdout = io.open(sys.stdout.fileno(), 'wb', 0)
    sys.stdout = io.TextIOWrapper(binstdout, encoding=sys.stdout.encoding, write_through=True)

  if args.chdir:
    os.chdir(args.chdir)
  args.func(args)

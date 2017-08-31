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
# =============================================================================
"""Tests for functions."""

from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

from tensorflow.python.framework import constant_op
from tensorflow.python.framework import dtypes
from tensorflow.python.ops import data_flow_ops
from tensorflow.python.ops import io_ops
from tensorflow.python.platform import test, gfile, googletest
from tensorflow.python.util import compat

import os
os.environ["IPTF_OFFLINE"] = "1"
os.environ["IPTF_PATH"] = googletest.GetTempDir()
import iptf

import json

class FileSystemTest(test.TestCase):
  def testReadWrite(self):
    with self.test_session() as sess:
      contents = "ASDASDASDASDASDAS"
      filename = "iptf://repo/root/foo"
      meta_filename = "iptf://meta/repo/root/foo"

      wf = io_ops.write_file(
          filename=constant_op.constant(filename),
          contents=constant_op.constant(contents))
      reader = io_ops.WholeFileReader("test_reader")
      queue = data_flow_ops.FIFOQueue(99, [dtypes.string], shapes=())
      queue.enqueue_many([[filename]]).run()
      queue.close().run()
      with sess.graph.control_dependencies([wf]):
        key, value = sess.run(reader.read(queue))
      self.assertEqual(key, compat.as_bytes(filename))
      self.assertEqual(value, compat.as_bytes(contents))

      queue2 = data_flow_ops.FIFOQueue(99, [dtypes.string], shapes=())
      queue2.enqueue_many([[meta_filename]]).run()
      queue2.close().run()
      key, value = sess.run(reader.read(queue2))

      d = json.loads(compat.as_str(value))
      ipfs_path = d["IpfsPath"]
      queue3 = data_flow_ops.FIFOQueue(99, [dtypes.string], shapes=())
      queue3.enqueue_many([[ipfs_path]]).run()
      queue3.close().run()
      with sess.graph.control_dependencies([wf]):
        key, value = sess.run(reader.read(queue3))
      self.assertEqual(key, compat.as_bytes(ipfs_path))
      self.assertEqual(value, compat.as_bytes(contents))

      with gfile.Open(meta_filename, "wb") as f:
          f.write(compat.as_bytes('{"command": "publish"}'))

      ipns_path = d["IpnsPath"]
      queue4 = data_flow_ops.FIFOQueue(99, [dtypes.string], shapes=())
      queue4.enqueue_many([[ipns_path]]).run()
      queue4.close().run()
      with sess.graph.control_dependencies([wf]):
        key, value = sess.run(reader.read(queue4))
      self.assertEqual(key, compat.as_bytes(ipns_path))
      self.assertEqual(value, compat.as_bytes(contents))


  def t2estBasic(self):
    with self.test_session() as sess:
      reader = io_ops.WholeFileReader("test_reader")
      queue = data_flow_ops.FIFOQueue(99, [dtypes.string], shapes=())
      queue.enqueue_many([["iptf://repo/root/tenAs"]]).run()
      queue.close().run()
      key, value = sess.run(reader.read(queue))
    self.assertEqual(key, compat.as_bytes("iptf://repo/root/tenAs"))
    self.assertEqual(value, compat.as_bytes("AAAAAAAAAA"))


if __name__ == "__main__":
  test.main()

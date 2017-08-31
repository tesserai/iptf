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

import os
import socket
import sys

from tensorflow.python.framework import load_library
from tensorflow.python.platform import resource_loader

def _with_awaiting_server(fn):
    # A hack so we can be confident that Go's init has completed.
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    conn = None
    try:
        s.bind(('127.0.0.1', 0))
        s.listen(1)
        port = s.getsockname()[1]
        fn(port)
        conn, _ = s.accept()
    finally:
        try:
            if conn:
                conn.close()
        finally:
            s.close()

def _load_file_system_libray(port):
    os.environ["IPTF_READY_PORT"] = str(port)
    file_system_library = os.path.join(resource_loader.get_root_dir_with_all_resources(),
                                   "../iptf/iptf/go/c_api/libipfs.so")
    load_library.load_file_system_library(file_system_library)

# Since the golang runtime takes some time to initialize, we listen on a
# randomly chosen socket for it to signal that the filesystem has been
# registered successfully.
_with_awaiting_server(_load_file_system_libray)

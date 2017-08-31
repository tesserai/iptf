The black magic that bridges the Go world to `tensorflow::FileSystem` and
friends. The main event here is `filesys.swigcxx`.

Most of this code was written by studying the [TensorFlow Customer Filesystem Plugin documentation](https://www.tensorflow.org/extend/add_filesys), and a few random
files in the TensorFlow source code, including `tensorflow/core/platform/file_system_test.cc`,
`tensorflow/core/platform/posix/posix_file_system.cc`,
`tensorflow/core/platform/hadoop/hadoop_file_system.cc`, and
`tensorflow/core/platform/hadoop/hadoop_file_system_test.cc`.

/* Copyright 2016 The TensorFlow Authors. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
==============================================================================*/

#include "tensorflow/core/lib/core/status_test_util.h"
#include "tensorflow/core/lib/gtl/stl_util.h"
#include "tensorflow/core/lib/io/path.h"
#include "tensorflow/core/platform/env.h"
#include "tensorflow/core/platform/file_system.h"
#include "tensorflow/core/platform/test.h"

#include "iptf/go/c_api/_cgo_export.h"

namespace tensorflow {
namespace {

class FileSystemTest : public ::testing::Test {
 protected:
  void SetUp() override {
    env_ = Env::Default();

    const ::testing::TestInfo* const test_info =
        ::testing::UnitTest::GetInstance()->current_test_info();

    repoRoot = io::JoinPath(
        testing::TmpDir(),
        strings::StrCat(test_info->test_case_name(), test_info->name()));

    GoString repoRootGo = GoString{repoRoot.data(),(GoInt)repoRoot.size()};
    ipfs = (FileSystem*) NewIpfsFileSystem(repoRootGo, true, false);
  }

  void TearDown() override {
    // Tear down temporary file and directories.
    int64 undeleted_files = 0;
    int64 undeleted_dirs = 0;
    ASSERT_TRUE(
        env_->DeleteRecursively(repoRoot, &undeleted_files, &undeleted_dirs)
            .ok());
    ASSERT_EQ(0, undeleted_files);
    ASSERT_EQ(0, undeleted_dirs);
  }

  string TmpDir(const string& path) {
    return "iptf://repo/root/" + path;
  }

  Status WriteString(const string& fname, const string& content) {
    std::unique_ptr<WritableFile> writer;
    TF_RETURN_IF_ERROR(ipfs->NewWritableFile(fname, &writer));
    TF_RETURN_IF_ERROR(writer->Append(content));
    TF_RETURN_IF_ERROR(writer->Close());
    return Status::OK();
  }

  Status ReadAll(const string& fname, string* content) {
    std::unique_ptr<RandomAccessFile> reader;
    TF_RETURN_IF_ERROR(ipfs->NewRandomAccessFile(fname, &reader));

    uint64 file_size = 0;
    TF_RETURN_IF_ERROR(ipfs->GetFileSize(fname, &file_size));

    content->resize(file_size);
    StringPiece result;
    TF_RETURN_IF_ERROR(
        reader->Read(0, file_size, &result, gtl::string_as_array(content)));
    if (file_size != result.size()) {
      return errors::DataLoss("expected ", file_size, " got ", result.size(),
                              " bytes");
    }
    return Status::OK();
  }

  Env* env_;
  string repoRoot;
  FileSystem* ipfs;
};

TEST_F(FileSystemTest, SimpleTest) {
  const string fname = TmpDir("SimpleTest");
  const string content = "abcdefghijklmn";

  TF_ASSERT_OK(WriteString(fname, content));

  // Check that we can correctly get a tensor memory.
  std::unique_ptr<ReadOnlyMemoryRegion> memory_region;
  TF_ASSERT_OK(ipfs->NewReadOnlyMemoryRegionFromFile(fname,
                                                             &memory_region));

  // The memory region can be bigger but not less than Tensor size.
  ASSERT_GE(memory_region->length(), content.size());
  EXPECT_EQ(content.data(),
            StringPiece(static_cast<const char*>(memory_region->data()),
                        content.size()));
  // Check that GetFileSize works.
  uint64 file_size = 0;
  TF_ASSERT_OK(ipfs->GetFileSize(fname, &file_size));
  EXPECT_EQ(content.size(), file_size);

  // Check that Stat works.
  FileStatistics stat;
  TF_ASSERT_OK(ipfs->Stat(fname, &stat));
  EXPECT_EQ(content.size(), stat.length);

  // Check that if file not found correct error message returned.
  EXPECT_EQ(
      error::NOT_FOUND,
      ipfs->NewReadOnlyMemoryRegionFromFile(TmpDir("bla-bla"), &memory_region)
          .code());

  // Check FileExists.
  TF_EXPECT_OK(ipfs->FileExists(fname));
  EXPECT_EQ(error::Code::NOT_FOUND,
            ipfs->FileExists(TmpDir("bla-bla-bla")).code());
}

TEST_F(FileSystemTest, RandomAccessFile) {
  const string fname = TmpDir("RandomAccessFile");
  const string content = "abcdefghijklmn";
  TF_ASSERT_OK(WriteString(fname, content));

  std::unique_ptr<RandomAccessFile> reader;
  TF_EXPECT_OK(ipfs->NewRandomAccessFile(fname, &reader));

  string got;
  got.resize(content.size());
  StringPiece result;
  TF_EXPECT_OK(
      reader->Read(0, content.size(), &result, gtl::string_as_array(&got)));
  EXPECT_EQ(content.size(), result.size());
  EXPECT_EQ(content, result);

  got.clear();
  got.resize(4);
  TF_EXPECT_OK(reader->Read(2, 4, &result, gtl::string_as_array(&got)));
  EXPECT_EQ(4, result.size());
  EXPECT_EQ(content.substr(2, 4), result);
}

TEST_F(FileSystemTest, WritableFile) {
  std::unique_ptr<WritableFile> writer;
  const string fname = TmpDir("WritableFile");
  TF_EXPECT_OK(ipfs->NewWritableFile(fname, &writer));
  TF_EXPECT_OK(writer->Append("content1,"));
  TF_EXPECT_OK(writer->Append("content2"));
  TF_EXPECT_OK(writer->Flush());
  TF_EXPECT_OK(writer->Sync());
  TF_EXPECT_OK(writer->Close());

  string content;
  TF_EXPECT_OK(ReadAll(fname, &content));
  EXPECT_EQ("content1,content2", content);

  TF_EXPECT_OK(ipfs->NewWritableFile(fname, &writer));
  TF_EXPECT_OK(writer->Append("content3"));
  TF_EXPECT_OK(writer->Flush());
  TF_EXPECT_OK(writer->Sync());
  TF_EXPECT_OK(writer->Close());

  TF_EXPECT_OK(ReadAll(fname, &content));
  EXPECT_EQ("content3", content);
}

TEST_F(FileSystemTest, NewAppendableFile) {
  std::unique_ptr<WritableFile> writer;
  const string fname = TmpDir("AppendableFile");
  TF_EXPECT_OK(ipfs->NewAppendableFile(fname, &writer));
  TF_EXPECT_OK(writer->Append("content1,"));
  TF_EXPECT_OK(writer->Append("content2"));
  TF_EXPECT_OK(writer->Flush());
  TF_EXPECT_OK(writer->Sync());
  TF_EXPECT_OK(writer->Close());

  string content;
  TF_EXPECT_OK(ReadAll(fname, &content));
  EXPECT_EQ("content1,content2", content);

  TF_EXPECT_OK(ipfs->NewAppendableFile(fname, &writer));
  TF_EXPECT_OK(writer->Append("content3"));
  TF_EXPECT_OK(writer->Flush());
  TF_EXPECT_OK(writer->Sync());
  TF_EXPECT_OK(writer->Close());

  TF_EXPECT_OK(ReadAll(fname, &content));
  EXPECT_EQ("content1,content2content3", content);
}

TEST_F(FileSystemTest, FileExists) {
  const string fname = TmpDir("FileExists");
  EXPECT_EQ(error::Code::NOT_FOUND, ipfs->FileExists(fname).code());
  TF_ASSERT_OK(WriteString(fname, "test"));
  TF_EXPECT_OK(ipfs->FileExists(fname));
}

TEST_F(FileSystemTest, GetChildren) {
  const string base = TmpDir("GetChildren");
  TF_EXPECT_OK(ipfs->CreateDir(base));

  EXPECT_EQ(error::Code::ALREADY_EXISTS, ipfs->CreateDir(base).code());

  const string file = io::JoinPath(base, "testfile.csv");
  TF_EXPECT_OK(WriteString(file, "blah"));
  const string subdir = io::JoinPath(base, "subdir");
  TF_EXPECT_OK(ipfs->CreateDir(subdir));

  std::vector<string> children;
  TF_EXPECT_OK(ipfs->GetChildren(base, &children));
  std::sort(children.begin(), children.end());
  EXPECT_EQ(std::vector<string>({"subdir", "testfile.csv"}), children);
}

TEST_F(FileSystemTest, DeleteFile) {
  const string fname = TmpDir("DeleteFile");
  EXPECT_FALSE(ipfs->DeleteFile(fname).ok());
  TF_ASSERT_OK(WriteString(fname, "test"));
  TF_EXPECT_OK(ipfs->DeleteFile(fname));
}

TEST_F(FileSystemTest, GetFileSize) {
  const string fname = TmpDir("GetFileSize");
  TF_ASSERT_OK(WriteString(fname, "test"));
  uint64 file_size = 0;
  TF_EXPECT_OK(ipfs->GetFileSize(fname, &file_size));
  EXPECT_EQ(4, file_size);
}

TEST_F(FileSystemTest, CreateDirStat) {
  const string dir = TmpDir("CreateDirStat");
  TF_EXPECT_OK(ipfs->CreateDir(dir));
  FileStatistics stat;
  TF_EXPECT_OK(ipfs->Stat(dir, &stat));
  EXPECT_TRUE(stat.is_directory);
}

TEST_F(FileSystemTest, DeleteDir) {
  const string dir = TmpDir("DeleteDir");
  EXPECT_FALSE(ipfs->DeleteDir(dir).ok());
  TF_EXPECT_OK(ipfs->CreateDir(dir));
  TF_EXPECT_OK(ipfs->DeleteDir(dir));
  FileStatistics stat;
  EXPECT_FALSE(ipfs->Stat(dir, &stat).ok());
}

TEST_F(FileSystemTest, RenameFile) {
  const string fname1 = TmpDir("RenameFile1");
  const string fname2 = TmpDir("RenameFile2");
  TF_ASSERT_OK(WriteString(fname1, "test"));
  TF_EXPECT_OK(ipfs->RenameFile(fname1, fname2));
  string content;
  TF_EXPECT_OK(ReadAll(fname2, &content));
  EXPECT_EQ("test", content);
}

TEST_F(FileSystemTest, RenameFile_Overwrite) {
  const string fname1 = TmpDir("RenameFile1");
  const string fname2 = TmpDir("RenameFile2");

  TF_ASSERT_OK(WriteString(fname2, "test"));
  TF_EXPECT_OK(ipfs->FileExists(fname2));

  TF_ASSERT_OK(WriteString(fname1, "test"));
  TF_EXPECT_OK(ipfs->RenameFile(fname1, fname2));
  string content;
  TF_EXPECT_OK(ReadAll(fname2, &content));
  EXPECT_EQ("test", content);
}

TEST_F(FileSystemTest, StatFile) {
  const string fname = TmpDir("StatFile");
  TF_ASSERT_OK(WriteString(fname, "test"));
  FileStatistics stat;
  TF_EXPECT_OK(ipfs->Stat(fname, &stat));
  EXPECT_EQ(4, stat.length);
  EXPECT_FALSE(stat.is_directory);
}

// TEST_F(FileSystemTest, WriteWhileReading) {
//   std::unique_ptr<WritableFile> writer;
//   const string fname = TmpDir("WriteWhileReading");
//   // Skip the test if we're not testing on HDFS. Hadoop's local filesystem
//   // implementation makes no guarantees that writable files are readable while
//   // being written.
//   if (!StringPiece(fname).starts_with("ipfs://")) {
//     return;
//   }
//
//   TF_EXPECT_OK(ipfs->NewWritableFile(fname, &writer));
//
//   const string content1 = "content1";
//   TF_EXPECT_OK(writer->Append(content1));
//   TF_EXPECT_OK(writer->Flush());
//
//   std::unique_ptr<RandomAccessFile> reader;
//   TF_EXPECT_OK(ipfs->NewRandomAccessFile(fname, &reader));
//
//   string got;
//   got.resize(content1.size());
//   StringPiece result;
//   TF_EXPECT_OK(
//       reader->Read(0, content1.size(), &result, gtl::string_as_array(&got)));
//   EXPECT_EQ(content1, result);
//
//   string content2 = "content2";
//   TF_EXPECT_OK(writer->Append(content2));
//   TF_EXPECT_OK(writer->Flush());
//
//   got.resize(content2.size());
//   TF_EXPECT_OK(reader->Read(content1.size(), content2.size(), &result,
//                             gtl::string_as_array(&got)));
//   EXPECT_EQ(content2, result);
//
//   TF_EXPECT_OK(writer->Close());
// }

}  // namespace
}  // namespace tensorflow

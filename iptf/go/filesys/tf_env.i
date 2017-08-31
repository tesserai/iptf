%include "tf_string.i"

namespace tensorflow {
  class Status {
   public:
    Status();
    ~Status();
    static Status OK();
  };

  class FileSystemRegistry {
   public:
    %ignore FileSystemRegistry();
    %ignore ~FileSystemRegistry();
    typedef std::function<FileSystem*()> Factory;
  };

  class Env {
   public:
     %ignore Env();
     %ignore ~Env();
     static Env* Default();
     virtual Status RegisterFileSystem(const string& scheme,
                                       FileSystemRegistry::Factory factory);
     virtual Status GetRegisteredFileSystemSchemes(std::vector<string>* schemes);
  };
};

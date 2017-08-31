#ifndef IPTF_SINGLETON_FILESYSTEM_FACTORY
#define IPTF_SINGLETON_FILESYSTEM_FACTORY

#include "tensorflow/core/platform/env.h"

namespace iptf {

template <class T>
tensorflow::FileSystemRegistry::Factory SingletonFileSystemFactory(T* t) {
  static_assert(std::is_base_of<tensorflow::FileSystem, T>::value, "T not derived from tensorflow::FileSystem");
  return static_cast<tensorflow::FileSystemRegistry::Factory>(
      [t]() -> tensorflow::FileSystem* { return t; });
}

};

#endif  // IPTF_SINGLETON_FILESYSTEM_FACTORY

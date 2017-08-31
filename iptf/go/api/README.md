Types defined in this package are Go-style adaptations of types that exist
in the C++ tensorflow::filesystem namespace. To preserve performance,
semantics are as close as possible. Where appropriate, we have substituted
Go-style conventions, such as using io.Writer instead of
tensorflow::WritableFile::Append(...).

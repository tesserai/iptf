with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "env";
  env = buildEnv { name = name; paths = buildInputs; };
  buildInputs = [
    python35Full
    python35Packages.wheel
    python35Packages.virtualenv

    python35Packages.numpy
    python35Packages.six
    python35Packages.werkzeug
    python35Packages.mock

    tmux
    zlib
  ];

  PYTHON_BIN_PATH = "${python35Full.outPath}/bin/python";
  PYTHON_LIB_PATH = "${python35Full.outPath}/lib/python3.5/site-packages";

  shellHook =
    ''
      export AR="/usr/bin/ar"
      export CC="/usr/bin/clang"
      export CXX="/usr/bin/clang++"
      export LD="/usr/bin/clang++"
    '';
}

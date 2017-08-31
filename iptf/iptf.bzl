# LINT.IfChange
def iptf_copts():
  return ([
      "-DEIGEN_AVOID_STL_ARRAY",
      "-Iexternal/gemmlowp",
      "-Wno-sign-compare",
      "-fno-exceptions",
      "-std=c++11",
  ])

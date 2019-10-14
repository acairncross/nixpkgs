{ stdenv, fetchFromGitHub, cmake, zlib, gmp, jdk8, git,
  # The JDK we use on Darwin currenly makes extensive use of rpaths which are
  # annoying and break the python library, so let's not bother for now
  includeJava ? !stdenv.hostPlatform.isDarwin, includeGplCode ? true }:

with stdenv.lib;

let
  boolToCmake = x: if x then "ON" else "OFF";

  rev    = "60528a380a2fd17e84d04e86f14b2349e8f9fa51";
  sha256 = "0604iaswg0rb56rvxyiid5c10ivg8f0fynqkmlm0icvw7ikrjrw9";

  pname   = "monosat";
  version = substring 0 7 sha256;

  src = fetchFromGitHub {
    owner = "sambayless";
    repo  = pname;
    inherit rev sha256;
  };

  core = stdenv.mkDerivation {
    name = "${pname}-${version}";
    inherit src;
    buildInputs = [ cmake zlib gmp jdk8 git ];

    cmakeFlags = [
      "-DBUILD_STATIC=OFF"
      "-DJAVA=${boolToCmake includeJava}"
      "-DGPL=${boolToCmake includeGplCode}"
    ];

    postInstall = optionalString includeJava ''
      mkdir -p $out/share/java
      cp monosat.jar $out/share/java
    '';

    passthru = { inherit python; };

    meta = {
      description = "SMT solver for Monotonic Theories";
      platforms   = platforms.unix;
      license     = if includeGplCode then licenses.gpl2 else licenses.mit;
      homepage    = https://github.com/sambayless/monosat;
      maintainers = [ maintainers.acairncross ];
    };
  };

  python = { buildPythonPackage, cython }: buildPythonPackage {
    inherit pname version src;

    # The top-level "source" is what fetchFromGitHub gives us. The rest is inside the repo
    sourceRoot = "source/src/monosat/api/python/";

    propagatedBuildInputs = [ core cython ];

    # This tells setup.py to use cython, which should produce faster bindings
    MONOSAT_CYTHON = true;

    # The relative paths here don't make sense for our Nix build
    # TODO: do we want to just reference the core monosat library rather than copying the
    # shared lib? The current setup.py copies the .dylib/.so...
    postPatch = ''
      substituteInPlace setup.py \
        --replace 'library_dir = "../../../../"' 'library_dir = "${core}/lib/"'
    '';
  };
in core

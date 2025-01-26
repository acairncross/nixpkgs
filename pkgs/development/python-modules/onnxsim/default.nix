{
  buildPythonPackage,
  fetchPypi,
  cmake,

  # dependencies
  onnxruntime,
  onnx,
  rich,
}:

buildPythonPackage rec {
  pname = "onnxsim";
  version = "0.4.36";
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-bg7p1tSoMEK973MZ++WDUtn9pfJTOGvismfHwn8GOO4=";
  };

  dontUseCmakeConfigure = true;

  nativeBuildInputs = [
    cmake
  ];

  dependencies = [
    onnx
    onnxruntime
    rich
  ];

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "setup_requires.append('pytest-runner')" ""
  '';
}

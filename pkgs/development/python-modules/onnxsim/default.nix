{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  cmake,
  versionCheckHook,
  pytestCheckHook,

  # dependencies
  onnxruntime,
  onnx,
  rich,

  # tests
  numpy,
  torch,
  torchvision,
}:

buildPythonPackage rec {
  pname = "onnxsim";
  version = "0.4.36";
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-bg7p1tSoMEK973MZ++WDUtn9pfJTOGvismfHwn8GOO4=";
  };

  dontUseCmakeConfigure = true;

  build-system = [
    setuptools
  ];

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

  pythonImportsCheck = [ "onnxsim" ];

  nativeCheckInputs = [
    versionCheckHook
    pytestCheckHook
    numpy
    torch
    torchvision
  ];

  versionCheckProgramArg = "-v";

  preInstallCheck = ''
    export HOME=$(mktemp -d)
    # This disables some problematic tests (e.g. tests which use a lot of RAM
    # or connect to the internet)
    export ONNXSIM_CI=1
    # There is a directory called onnxsim in the current directory which
    # contains C++ sources. We don't want this to get picked up by
    # `import onnxsim` so rename it (it could even be deleted).
    mv onnxsim onnxsim-src
  '';

  disabledTestPaths = [
    # Don't run tests that are part of submodules
    "third_party/"
  ];

  meta = {
    description = "Simplify your ONNX model";
    homepage = "https://github.com/daquexian/onnx-simplifier";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ osbm acairncross ];
  };
}

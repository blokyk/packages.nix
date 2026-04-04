{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "console-window";
  version = "1.3.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "joedefen";
    repo = "console-window";
    rev = "1acbe3a69e2134ca868148c7a388dee227bd2fad";
    hash = "sha256-1WebDvucRKVwlueMamsCgCp3t/WzNIsl/uIUjmnWx1Q=";
  };

  build-system = [
    python3Packages.flit-core
  ];

  pythonImportsCheck = [
    "console_window"
  ];

  meta = {
    description = "Python Wrapper for curses that Eases Development of Many Apps";
    homepage = "https://github.com/joedefen/console-window";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ blokyk ];
  };
})

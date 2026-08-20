{
  lib,
  pins,
  python3Packages,
}:
python3Packages.buildPythonPackage (finalAttrs: {
  pname = "console-window";
  version = "1.3.2";
  pyproject = true;

  src = pins.console-window;

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

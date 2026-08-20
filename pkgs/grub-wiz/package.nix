{
  callPackage,
  console-window ? callPackage ./console-window.nix {},
  lib,
  pins,
  python3Packages,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "grub-wiz";
  version = "0.8.19";
  pyproject = true;

  src = pins.grub-wiz;

  build-system = [
    python3Packages.flit-core
  ];

  dependencies = [
    console-window
    python3Packages.ruamel-yaml
  ];

  pythonImportsCheck = [
    "grub_wiz"
  ];

  meta = {
    description = "GrubWiz: The Helpful GRUB Bootloader Assistant";
    homepage = "https://github.com/joedefen/grub-wiz";
    platforms = lib.platforms.linux;
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ blokyk ];
    mainProgram = "grub-wiz";
  };
})

{
  callPackage,
  console-window ? callPackage ./console-window.nix {},
  fetchFromGitHub,
  lib,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "grub-wiz";
  version = "0.8.19";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "joedefen";
    repo = "grub-wiz";
    rev = "529b7446ace8f676a0899bea3518e7c25934f307";
    hash = "sha256-MMZuXb9UA+wsf9UV3Mu19spqoSFW+vslT0R098Is9lY=";
  };

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

{
  lib,
  pins,
  python3Packages,
}:
python3Packages.buildPythonApplication (finalAttrs:
let
  setup_py = lib.toFile "setup.py" ''
    from setuptools import setup

    setup(
      name = '${finalAttrs.pname}',
      version = '${finalAttrs.version}',
      author = 'mbrukman',
      description = 'Visually select and extract regions from PDFs into SVGs. No more pixelated screenshots!',
      scripts = [
        'app.py',
      ],
      # explicitely specify not to search for any other package in the source tree
      packages = [],
    )
  '';
in {
  pname = "pdf-extract-svg";
  version = "0.1+unstable-2026-01-16";
  pyproject = true;

  src = pins.pdf-extract-svg;

  prePatch = ''
    # add a basic setup.py file
    cp "${setup_py}" ./setup.py
  '';

  build-system = [ python3Packages.setuptools ];

  dependencies = with python3Packages; [
    pyside6
    mypy
  ];

  postInstall = ''
    mv -v "$out/bin/app.py" "$out/bin/pdf-extract-svg"
  '';

  meta = {
    description = "Visually select and extract regions from PDFs into SVGs. No more pixelated screenshots!";
    homepage = "https://github.com/mbrukman/pdf-extract-svg";
    platforms = lib.platforms.unix;
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ blokyk ];
    mainProgram = "pdf-extract-svg";
  };
})

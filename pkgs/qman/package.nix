{
  lib,
  pins,

  bzip2,
  cunit,
  groff,
  man,
  meson,
  ncurses,
  ninja,
  pkg-config,
  stdenv,
  xz,
  zlib,

  python314Packages,
  cogapp ? python314Packages.cogapp,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "qman";
  # strip the 'v' at the start
  version = lib.substring 0 (-1) pins.qman.version;

  src = pins.qman;

  nativeBuildInputs = [
    cogapp
    cunit
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    bzip2
    # cunit
    groff
    man
    ncurses
    xz
    zlib
  ];

  mesonFlags = [
    # fixme: why doesn't src/qman_tests_list.sh work???
    # (also this doesn't matter that much because there's only one test right now)
    (lib.mesonEnable "tests" false)

    # disable installing config files because we don't want them at installation
    (lib.mesonEnable "config" false)
  ];

  outputs = [ "out" "doc" "man" ];

  meta = {
    description = "A more modern man page viewer";
    homepage = "https://github.com/plp13/qman";
    license = lib.licenses.bsd2;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ blokyk ];
    mainProgram = "qman";
  };
})

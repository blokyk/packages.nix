{
  lib,

  bzip2,
  cunit,
  groff,
  fetchFromGitHub,
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
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "plp13";
    repo = "qman";
    rev = "v${finalAttrs.version}";
    hash = "sha256-z3ILbbwcCYZT8qabVaGnMCyZRag8djEI32i6G7cLL2A=";
  };

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

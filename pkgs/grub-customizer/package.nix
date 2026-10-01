{
  lib,
  stdenv,
  pins,

  cmake,
  gettext,
  pkg-config,
  makeWrapper,

  gtkmm3,
  openssl,
  libarchive,

  grub2,
  hwinfo,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "grub-customizer";
  version = "5.2.8";

  src = pins.grub-customizer;

  patches = [
    ./no-fhs-install.patch
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    gettext
    makeWrapper
  ];

  buildInputs = [
    gtkmm3
    openssl
    libarchive
  ];

  outputs = [ "out" "man" ];

  postInstall = ''
    wrapProgram $out/bin/grub-customizer \
      --suffix PATH : '${lib.makeBinPath [ grub2 hwinfo ]}'

    install -Dm644 "$src/misc/grub-customizer.desktop" "$out/share/applications"
  '';

  passthru.desktopItem = "${finalAttrs.src}/misc/grub-customizer.desktop";

  meta = {
    description = "Graphical interface to configure the GRUB2/BURG settings and menuentries";
    homepage = "launchpad.net/grub-customizer";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ blokyk ];
    mainProgram = "grub-customizer";
  };
})

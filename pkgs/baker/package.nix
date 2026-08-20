{
  lib,
  pins,
  rustPlatform,

  libgit2,
  openssl,
  perl,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "baker";
  # strip the 'v' at the start
  version = lib.substring 1 (-1) pins.baker.version;

  src = pins.baker;

  # we have to vendor a Cargo.lock because the original repo doesn't have one
  cargoLock.lockFile = ./Cargo.lock;
  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [ perl ];

  buildInputs = [
    libgit2
    openssl
  ];

  meta = {
    description = "A command-line tool that helps you quickly scaffold new projects.";
    longDescription = ''
      Baker is a command-line tool that helps you quickly scaffold new projects.
      It supports language-independent hooks for automating routine tasks.
      Baker is written in Rust and distributed as a standalone binary.
    '';
    homepage = "https://github.com/aliev/baker";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "baker";
    maintainers = with lib.maintainers; [ blokyk ];
  };
})

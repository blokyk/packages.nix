{
  buildRustPackage ? rustPlatform.buildRustPackage,
  rustPlatform,
  sqlite,

  lib,
  pins
}:
buildRustPackage (finalAttrs: {
  pname = "jdbrowser";
  version = pins.jdbrowser.version;

  src = pins.jdbrowser;

  cargoLock.lockFile = "${finalAttrs.src}/Cargo.lock";

  buildInputs = [ sqlite ];

  meta = {
    description = "A terminal SQLite database browser, written in Rust.";
    homepage = "https://github.com/Jkeyuk/JDbrowser";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ blokyk ];
    mainProgram = "jdbrowser";
  };
})

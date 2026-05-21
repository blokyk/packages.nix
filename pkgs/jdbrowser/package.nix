{
  buildRustPackage ? rustPlatform.buildRustPackage,
  fetchFromGitHub,
  rustPlatform,
  sqlite,

  lib,
}:
buildRustPackage (finalAttrs: {
  pname = "jdbrowser";
  version = "1.4";

  src = fetchFromGitHub {
    owner = "Jkeyuk";
    repo = "JDbrowser";
    rev = finalAttrs.version;
    hash = "sha256-0i0JNrmphqCVC5vAndHMRZDeRrbUZwJVvz82IKOldOk=";
  };

  cargoLock.lockFile = "${finalAttrs.src}/Cargo.lock";

  buildInputs = [ sqlite ];

  meta = {
    description = "A terminal SQLite database browser, written in Rust.";
    homepage = "https://github.com/Jkeyuk/JDbrowser";
    license = lib.licenses.gpl3Plus;
    platforms = [ lib.platforms.linux ];
    maintainers = with lib.maintainers; [ blokyk ];
    mainProgram = "jdbrowser";
  };
})

{
  buildRustPackage ? rustPlatform.buildRustPackage,
  fetchFromGitHub,
  rustPlatform,
  sqlite,

  lib,
}: buildRustPackage (finalAttrs: {
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
    description = "Fork of lf-'s 'nix-otel', a Nix OpenTelemetry sender plugin.";
    homepage = "https://github.com/blokyk/nix-otel";
    license = lib.licenses.gpl3Plus;
    platform = lib.platforms.linux;
    maintainers = with lib.maintainers; [ blokyk ];
  };
})